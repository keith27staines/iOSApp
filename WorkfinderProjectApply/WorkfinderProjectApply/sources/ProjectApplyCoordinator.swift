
import WorkfinderCommon
import WorkfinderCoordinators
import WorkfinderServices
import WorkfinderCoverLetter
import WorkfinderAppLogic
import WorkfinderDocumentUpload
import WorkfinderUI
import ErrorHandlingUI
import WorkfinderRegisterCandidate
import WorkfinderCandidateProfile
import StoreKit

public class ProjectApplyCoordinator: ProjectApplyBaseCoordinator, ProjectApplyCoordinatorProtocol {
    
    let projectUuid: F4SUUID
    weak var modalVC: ProjectViewController?
    weak var originalVC: UIViewController?
    var projectPresenter: ProjectPresenter?
    
    public init(
        parent: ProjectApplyCoordinatorDelegate?,
        navigationRouter: NavigationRoutingProtocol,
        inject: CoreInjectionProtocol,
        projectUuid: F4SUUID,
        appSource: AppSource,
        switchToTab: ((TabIndex) -> Void)?
    ) {
        self.projectUuid = projectUuid
        super.init(
            parent: parent,
            navigationRouter: navigationRouter,
            inject: inject,
            appSource: appSource,
            switchToTab: switchToTab)
    }
    
    public override func start() {
        originalVC = navigationRouter.navigationController.topViewController
        let presenter = ProjectPresenter(
            coordinator: self,
            projectUuid: projectUuid,
            projectService: ProjectService(networkConfig: injected.networkConfig),
            source: appSource,
            log: injected.log
        )
        self.projectPresenter = presenter
        let vc = ProjectViewController(
            coordinator: self,
            presenter: presenter,
            appSource: appSource,
            log: log
        )
        let newNav = UINavigationController(rootViewController: vc)
        newNav.modalPresentationStyle = .fullScreen
        originalVC?.present(newNav, animated: true, completion: nil)
        modalVC = vc
        activeNavigationRouter = NavigationRouter(navigationController: newNav)
    }
    
    func startCoverLetterFlow() {
        let user = UserRepository().loadUser()
        let candidate = UserRepository().loadCandidate()
        let association = projectPresenter?.association
        let projectTitle = projectPresenter?.project.name
        
        let companyName = association?.location?.company?.name ?? "your company"
        let hostName = projectPresenter?.host?.fullName ?? "Sir/Madam"
    
        let coordinator = CoverLetterFlowFactory.makeFlow(
            type: .projectApplication,
            parent: self,
            navigationRouter: activeNavigationRouter,
            inject: injected,
            candidateAge: candidate.age() ?? 18,
            candidateName: user.fullname,
            isProject: true,
            projectTitle: projectTitle,
            companyName: companyName,
            hostName: hostName)
        addChildCoordinator(coordinator)
        coordinator.start()
    }

    override func onTapApply() {
        log.track(.project_apply_start(appSource))
        log.track(.placement_funnel_start(appSource))
        startCoverLetterFlow()
    }
    
    override func onModalFinished() {
        originalVC?.dismiss(animated: true, completion: nil)
        delegate?.onProjectApplyDidFinish()
        parentCoordinator?.childCoordinatorDidFinish(self)
    }
    
    override func submitApplication() {
        self.log.track(.placement_funnel_convert(self.appSource))
        guard let vc = modalVC, let view = vc.view else { return }
        var picklistsDictionary = self.picklistsDictionary
        picklistsDictionary[.availabilityPeriod] = nil
        picklistsDictionary[.duration] = nil
        let messageHandler = vc.messageHandler
        messageHandler.showLoadingOverlay(view)
        placementService = PostPlacementService(networkConfig: injected.networkConfig)
        let builder = DraftPlacementPreparer()
        builder.update(candidateUuid: UserRepository().loadCandidate().uuid)
        builder.update(picklists: picklistsDictionary)
        builder.update(associationUuid: projectPresenter?.association?.uuid)
        builder.update(associatedProject: projectPresenter?.project.uuid)
        builder.update(coverletter: coverLetterText)
        placementService = PostPlacementService(networkConfig: injected.networkConfig)
        placementService?.postPlacement(draftPlacement: builder.draft) { [weak self] (result) in
            guard let self = self else { return }
            messageHandler.hideLoadingOverlay()
            switch result {
            case .success(let placement):
                self.log.track(.project_apply_convert(self.appSource))
                self.onApplicationSubmitted(placement: placement)
            case .failure(let error):
                messageHandler.displayOptionalErrorIfNotNil(error, cancelHandler: {
                    // just dismiss
                }, retryHandler: {
                    self.submitApplication()
                })
            }
        }
    }
    
    func onApplicationSubmitted(placement: PostPlacementJson) {
        guard let placementUuid = placement.uuid else { return }
        let coordinator = DocumentUploadCoordinator(
            parent: self,
            navigationRouter: activeNavigationRouter,
            inject: injected, delegate: self,
            appModel: .placement,
            objectUuid: placementUuid,
            showBackButton: false
        )
        addChildCoordinator(coordinator)
        coordinator.start()
    }
    
    func showSuccess() {
        let vc = SuccessViewController(
            applicationsButtonTap: { [weak self] in
                self?.dismissSuccessSwitchingTo(.applications)
        },
            searchButtonTap: { [weak self] in
                self?.dismissSuccessSwitchingTo(.home)
        })
        vc.modalPresentationStyle = .overCurrentContext
        modalVC?.present(vc, animated: false, completion: nil)
        successViewController = vc
    }
    
    func dismissSuccessSwitchingTo(_ tabIndex: TabIndex) {
        successViewController?.dismiss(animated: true, completion: nil)
        onModalFinished()
        switchToTab?(tabIndex)
        injected.requestAppReviewLogic.makeRequest()
    }
}

extension ProjectApplyCoordinator: CoverLetterParentCoordinatorProtocol {
    public var coverLetterPrimaryButtonText: String { "Apply now!" }
    public func coverLetterDidCancel() {
        onCoverLetterWorkflowCancelled()
    }
    public func coverLetterCoordinatorDidComplete(coverLetterText: String, picklistsDictionary: PicklistsDictionary) {
        self.coverLetterText = coverLetterText
        self.picklistsDictionary = picklistsDictionary
        onCoverLetterDidComplete()
    }
}

extension ProjectApplyCoordinator: DocumentUploadCoordinatorParentProtocol {
    public func onSkipDocumentUpload() {
        showSuccess()
    }
    
    public func onUploadComplete() {
        showSuccess()
    }
}
