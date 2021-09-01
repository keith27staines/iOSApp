
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

public class ProjectQuickApplyCoordinator: ProjectApplyBaseCoordinator, ProjectApplyCoordinatorProtocol {
    
    var projectInfoPresenter: ProjectInfoPresenter
    weak var presentingViewController: UIViewController?
    
    public init(
        parent: ProjectApplyCoordinatorDelegate?,
        navigationRouter: NavigationRoutingProtocol,
        presentingViewController: UIViewController,
        inject: CoreInjectionProtocol,
        projectInfoPresenter: ProjectInfoPresenter,
        appSource: AppSource,
        switchToTab: ((TabIndex) -> Void)?
    ) {
        self.projectInfoPresenter = projectInfoPresenter
        self.presentingViewController = presentingViewController
        super.init(
            parent: parent,
            navigationRouter: navigationRouter,
            inject: inject,
            appSource: appSource,
            switchToTab: switchToTab
        )
    }
    
    public override func start() {
        let user = UserRepository().loadUser()
        let candidate = UserRepository().loadCandidate()
        let coordinator = CoverLetterFlowFactory.makeFlow(
            type: .projectApplication,
            parent: self,
            navigationRouter: activeNavigationRouter,
            inject: injected,
            candidateAge: candidate.age() ?? 18,
            candidateName: user.fullname,
            isProject: true,
            projectTitle: projectInfoPresenter.projectName,
            companyName: projectInfoPresenter.companyName,
            hostName: projectInfoPresenter.hostName)
        addChildCoordinator(coordinator)
        coordinator.start()
        messageHandler = coordinator.messageHandler
    }
    
    override func onTapApply() {
        // nothing to do here as the screen showing the apply button is not part of this flow
    }
        
    override func onModalFinished() {
        guard let presentingViewController = presentingViewController else { return }
        navigationRouter.popToViewController(presentingViewController, animated: true)
        delegate?.onProjectApplyDidFinish()
        parentCoordinator?.childCoordinatorDidFinish(self)
    }
    
    override func submitApplication() {
        self.log.track(.placement_funnel_convert(self.appSource))
        // guard let vc = modalVC, let view = vc.view else { return }
        var picklistsDictionary = self.picklistsDictionary
        picklistsDictionary[.availabilityPeriod] = nil
        picklistsDictionary[.duration] = nil
        messageHandler?.showLoadingOverlay()
        placementService = PostPlacementService(networkConfig: injected.networkConfig)
        let builder = DraftPlacementPreparer()
        builder.update(candidateUuid: UserRepository().loadCandidate().uuid)
        builder.update(picklists: picklistsDictionary)
        builder.update(associationUuid: projectInfoPresenter.associationUuid)
        builder.update(associatedProject: projectInfoPresenter.projectUuid)
        builder.update(coverletter: coverLetterText)
        placementService = PostPlacementService(networkConfig: injected.networkConfig)
        placementService?.postPlacement(draftPlacement: builder.draft) { [weak self] (result) in
            guard let self = self else { return }
            self.messageHandler?.hideLoadingOverlay()
            switch result {
            case .success(let placement):
                self.log.track(.project_apply_convert(self.appSource))
                self.onApplicationSubmitted(placement: placement)
            case .failure(let error):
                self.messageHandler?.displayOptionalErrorIfNotNil(error, cancelHandler: {
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
            navigationRouter: navigationRouter,
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
        navigationRouter.navigationController.topViewController?.present(vc, animated: false, completion: nil)
        successViewController = vc
    }
    
    func dismissSuccessSwitchingTo(_ tabIndex: TabIndex) {
        successViewController?.dismiss(animated: true, completion: nil)
        onModalFinished()
        switchToTab?(tabIndex)
        injected.requestAppReviewLogic.makeRequest()
    }
}

extension ProjectQuickApplyCoordinator: CoverLetterParentCoordinatorProtocol {
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

extension ProjectQuickApplyCoordinator: DocumentUploadCoordinatorParentProtocol {
    public func onSkipDocumentUpload() {
        showSuccess()
    }
    
    public func onUploadComplete() {
        showSuccess()
    }
}
