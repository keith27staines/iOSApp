
import WorkfinderCommon
import WorkfinderCoordinators
import WorkfinderServices
import WorkfinderCoverLetter
import WorkfinderAppLogic
import WorkfinderDocumentUpload
import WorkfinderUI
import ErrorHandlingUI
import WorkfinderRegisterCandidate
import StoreKit

protocol ProjectApplyCoordinatorProtocol: AnyObject, ErrorHandlerProviderProtocol {
    func onCoverLetterWorkflowCancelled()
    func onModalFinished()
    func onTapApply()
}

public protocol ProjectApplyCoordinatorDelegate: Coordinating {
    func onProjectApplyDidFinish()
}

public class ProjectApplyCoordinator: CoreInjectionNavigationCoordinator {
    
    let projectUuid: F4SUUID
    weak var modalVC: ProjectViewController?
    weak var originalVC: UIViewController?
    var projectPresenter: ProjectPresenter?
    var newNavigationRouter:NavigationRouter!
    var switchToTab: ((TabIndex) -> Void)?
    weak var successViewController: UIViewController?
    var placementService: PostPlacementServiceProtocol?
    var delegate: ProjectApplyCoordinatorDelegate?
    var projectType: String = ""
    var log: F4SAnalyticsAndDebugging { injected.log }
    let appSource: AppSource
    var coverLetterText: String = ""
    var picklistsDictionary = PicklistsDictionary()
    
    lazy public var errorHandler: ErrorHandlerProtocol = {
        ErrorHandler(
            navigationRouter: self.newNavigationRouter,
            coreInjection: self.injected,
            parentCoordinator: self)
    }()
    
    public init(
        parent: ProjectApplyCoordinatorDelegate?,
        navigationRouter: NavigationRoutingProtocol,
        inject: CoreInjectionProtocol,
        projectUuid: F4SUUID,
        appSource: AppSource,
        switchToTab: ((TabIndex) -> Void)?
    ) {
        self.delegate = parent
        self.appSource = appSource
        self.switchToTab = switchToTab
        self.projectUuid = projectUuid
        super.init(parent: parent, navigationRouter: navigationRouter, inject: inject)
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
        newNavigationRouter = NavigationRouter(navigationController: newNav)
    }
    
    func startCoverLetterFlow() {
        let candidate = UserRepository().loadCandidate()
        let association = projectPresenter?.association
        let projectTitle = projectPresenter?.project.name
        guard
            let companyName = association?.location?.company?.name,
            let hostName = association?.host?.fullName
            else { return }
        
        let coordinator = CoverLetterFlowFactory.makeFlow(
            type: .projectApplication,
            parent: self,
            navigationRouter: newNavigationRouter,
            inject: injected,
            candidateAge: candidate.age() ?? 18,
            candidateName: candidate.fullName,
            isProject: true,
            projectTitle: projectTitle,
            companyName: companyName,
            hostName: hostName)
        addChildCoordinator(coordinator)
        coordinator.start()

    }
    
    func showAlert(title: String, message: String, buttonTitle: String) {
        guard
            let topVC = navigationRouter.navigationController.topViewController
            else { return }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancel = UIAlertAction(title: buttonTitle, style: .cancel, handler: nil)
        alert.addAction(cancel)
        topVC.present(alert, animated: true, completion: nil)
    }
}

extension ProjectApplyCoordinator: ProjectApplyCoordinatorProtocol {
    
    func onTapApply() {
        log.track(.project_apply_start(appSource))
        log.track(.placement_funnel_start(appSource))
        startCoverLetterFlow()
    }
    
    func onModalFinished() {
        originalVC?.dismiss(animated: true, completion: nil)
        delegate?.onProjectApplyDidFinish()
        parentCoordinator?.childCoordinatorDidFinish(self)
    }
    
    func onCoverLetterWorkflowCancelled() {
        log.track(.placement_funnel_cancel(appSource))
        log.track(.project_apply_cancel(appSource))
    }
    
    func onCoverLetterDidComplete() {
        switch UserRepository().isCandidateLoggedIn {
        case true: submitApplication()
        case false: startLogin()
        }
    }
    
    func startLogin() {
        let coordinator = RegisterAndSignInCoordinator(
            parent: self,
            navigationRouter: newNavigationRouter,
            inject: injected,
            firstScreenHidesBackButton: true)
        addChildCoordinator(coordinator)
        coordinator.startLoginFirst()
    }
    
    func submitApplication() {
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
    
    func onApplicationSubmitted(placement: Placement) {
        guard let placementUuid = placement.uuid else { return }
        let coordinator = DocumentUploadCoordinator(
            parent: self,
            navigationRouter: newNavigationRouter,
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

extension ProjectApplyCoordinator: RegisterAndSignInCoordinatorParent {
    public func onCandidateIsSignedIn() {
        submitApplication()
    }
    
    public func onRegisterAndSignInCancelled() {
        newNavigationRouter.pop(animated: true)
    }
    
    
}
