
import WorkfinderCommon
import WorkfinderCoordinators
import WorkfinderServices
import WorkfinderCoverLetter
import WorkfinderAppLogic
import WorkfinderDocumentUpload
import WorkfinderUI
import ErrorHandlingUI
import WorkfinderRegisterCandidate

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
    var navigateToSearch: (() -> Void)?
    var navigateToApplications: (() -> Void)?
    weak var successViewController: UIViewController?
    var placementService: PostPlacementServiceProtocol?
    var delegate: ProjectApplyCoordinatorDelegate?
    var projectType: String = ""
    var log: F4SAnalytics { injected.log }
    let applicationSource: ApplicationSource
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
        applicationSource: ApplicationSource,
        navigateToSearch: (() -> Void)?,
        navigateToApplications: (() -> Void)?) {
        self.delegate = parent
        self.applicationSource = applicationSource
        self.navigateToSearch = navigateToSearch
        self.navigateToApplications = navigateToApplications
        self.projectUuid = projectUuid
        super.init(parent: parent, navigationRouter: navigationRouter, inject: inject)
    }
    
    public override func start() {
        originalVC = navigationRouter.navigationController.topViewController
        let presenter = ProjectPresenter(
            coordinator: self,
            projectUuid: projectUuid,
            projectService: ProjectService(networkConfig: injected.networkConfig),
            source: applicationSource,
            log: injected.log
        )
        self.projectPresenter = presenter
        let vc = ProjectViewController(coordinator: self, presenter: presenter)
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
        log.track(TrackingEvent(type: .uc_projectApply_start(applicationSource)))
        startCoverLetterFlow()
    }
    
    func onModalFinished() {
        originalVC?.dismiss(animated: true, completion: nil)
        delegate?.onProjectApplyDidFinish()
        log.track(TrackingEvent(type: .uc_projectApply_convert(applicationSource)))
        parentCoordinator?.childCoordinatorDidFinish(self)
    }
    
    func onCoverLetterWorkflowCancelled() {
        log.track(TrackingEvent(type: .uc_projectApply_cancel(applicationSource)))
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
                self.log.track(TrackingEvent(type: .uc_onboarding_convert))
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
                guard let self = self else { return }
                self.successViewController?.dismiss(animated: true, completion: nil)
                self.onModalFinished()
                self.navigateToApplications?()
                
        },
            searchButtonTap: { [weak self] in
                guard let self = self else { return }
                self.successViewController?.dismiss(animated: true, completion: nil)
                self.onModalFinished()
                self.navigateToSearch?()
        })
        vc.modalPresentationStyle = .overCurrentContext
        modalVC?.present(vc, animated: false, completion: nil)
        successViewController = vc
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
