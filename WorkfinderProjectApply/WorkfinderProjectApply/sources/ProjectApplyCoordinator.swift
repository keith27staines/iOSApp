
import WorkfinderCommon
import WorkfinderCoordinators
import WorkfinderServices
import WorkfinderCoverLetter
import WorkfinderAppLogic

protocol ProjectApplyCoordinatorProtocol: AnyObject {
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
    
    public init(
        parent: ProjectApplyCoordinatorDelegate?,
        navigationRouter: NavigationRoutingProtocol,
        inject: CoreInjectionProtocol,
        projectUuid: F4SUUID,
        navigateToSearch: (() -> Void)?,
        navigateToApplications: (() -> Void)?) {
        self.delegate = parent
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
            projectService: ProjectAndAssociationDetailsService(networkConfig: injected.networkConfig)
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
        let associationDetail = projectPresenter?.detail.associationDetail
        let projectTitle = projectPresenter?.detail.projectType?.name
        guard
            let companyName = associationDetail?.company?.name,
            let hostName = associationDetail?.host?.displayName
            else { return }
        
        guard
            let dobString = candidate.dateOfBirth,
            let _ = Date.workfinderDateStringToDate(dobString)
            else {
            showAlert(
                title: "Cannot Apply",
                message: "We need to know your name and other details before you can apply",
                buttonTitle: "Cancel"
            )
            return
        }
        let coordinator = CoverLetterFlowFactory.makeFlow(
            type: .projectApplication,
            parent: self,
            navigationRouter: newNavigationRouter,
            inject: injected,
            candidateAge: candidate.age() ?? 0,
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
        startCoverLetterFlow()
    }
    
    func onModalFinished() {
        originalVC?.dismiss(animated: true, completion: nil)
        delegate?.onProjectApplyDidFinish()
        parentCoordinator?.childCoordinatorDidFinish(self)
    }
    
    func onCoverLetterWorkflowCancelled() {
        // nothing to do here
    }
    
    func submitApplication(coverLetterText: String, picklistsDictionary: PicklistsDictionary) {
        guard let vc = modalVC, let view = vc.view else { return }
        var picklistsDictionary = picklistsDictionary
        picklistsDictionary[.availabilityPeriod] = nil
        picklistsDictionary[.duration] = nil
        let messageHandler = vc.messageHandler
        messageHandler.showLoadingOverlay(view)
        placementService = PostPlacementService(networkConfig: injected.networkConfig)
        let builder = DraftPlacementPreparer()
        builder.update(candidateUuid: UserRepository().loadCandidate().uuid)
        builder.update(picklists: picklistsDictionary)
        builder.update(associationUuid: projectPresenter?.detail.project?.association)
        builder.update(associatedProject: projectPresenter?.detail.project?.uuid)
        builder.update(coverletter: coverLetterText)
        placementService = PostPlacementService(networkConfig: injected.networkConfig)
        placementService?.postPlacement(draftPlacement: builder.draft) { [weak self] (result) in
            guard let self = self else { return }
            messageHandler.hideLoadingOverlay()
            switch result {
            case .success(_):
                self.onApplicationSubmitted()
            case .failure(let error):
                messageHandler.displayOptionalErrorIfNotNil(error, cancelHandler: {
                    // just dismiss
                }, retryHandler: {
                    self.submitApplication(coverLetterText: coverLetterText, picklistsDictionary: picklistsDictionary)
                })
            }
        }
    }
    
    func onApplicationSubmitted() {
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
        submitApplication(coverLetterText: coverLetterText, picklistsDictionary: picklistsDictionary)
    }
}
