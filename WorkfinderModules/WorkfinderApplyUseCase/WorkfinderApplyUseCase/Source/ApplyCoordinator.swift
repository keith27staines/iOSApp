
import Foundation
import WorkfinderCommon
import WorkfinderServices
import WorkfinderAppLogic
import WorkfinderUI
import WorkfinderCoordinators
import WorkfinderDocumentUploadUseCase
import WorkfinderUserDetailsUseCase

let __bundle = Bundle(identifier: "com.workfinder.WorkfinderApplyUseCase")!

public protocol ApplyCoordinatorDelegate : class {
    func applicationDidFinish(preferredDestination: PreferredDestination)
    func applicationDidCancel()
}

public class ApplyCoordinator : CoreInjectionNavigationCoordinator {
    var applicationSubmitter: ApplicationSubmitter?
    var userRepository: UserRepositoryProtocol { injected.userRepository }
    var coverletterCoordinator: CoverletterCoordinatorProtocol?
    var rootViewController: UIViewController?
    let environment: EnvironmentType
    var interestsRepository: F4SInterestsRepositoryProtocol
    let startingViewController: UIViewController!
    let applyService: PostPlacementServiceProtocol
    weak var applyCoordinatorDelegate: ApplyCoordinatorDelegate?
    lazy var userInterests: [F4SInterest] = { return interestsRepository.loadInterestsArray() }()
    var draftPlacement = Placement()
    
    lazy var applicationModel: ApplicationModel = {
        return ApplicationModel()
    }()
    
    lazy var successPopup: SuccessPopupView = {
        return SuccessPopupView(leftButtonTapped: { [weak self] in
            self?.removeApplicationSubmittedSuccessfully()
            self?.applyCoordinatorDelegate?.applicationDidFinish(preferredDestination: .applications)
        }) { [weak self] in
            self?.removeApplicationSubmittedSuccessfully()
            self?.applyCoordinatorDelegate?.applicationDidFinish(preferredDestination: .search)
        }
    }()
    
    private func showApplicationSubmittedSuccessfully() {
        guard let window = UIApplication.shared.keyWindow
            else { return }
        let navigationController = navigationRouter.navigationController
        window.addSubview(successPopup)
        navigationController.navigationBar.layer.zPosition = -1
        successPopup.frame = window.bounds
    }
    
    private func removeApplicationSubmittedSuccessfully() {
        successPopup.removeFromSuperview()
        let navigationController = navigationRouter.navigationController
        navigationController.navigationBar.layer.zPosition = 0
    }
    
    var isUserRegistrationWorkflowRequired: Bool {
        let userRepository = injected.userRepository
        let candidate = userRepository.loadCandidate()
        return candidate.uuid == nil
    }
    
    let association: HostLocationAssociationJson
    let companyWorkplace: CompanyWorkplace
    public init(applyCoordinatorDelegate: ApplyCoordinatorDelegate? = nil,
                applyService: PostPlacementServiceProtocol,
                companyWorkplace: CompanyWorkplace,
                association: HostLocationAssociationJson,
                parent: CoreInjectionNavigationCoordinator?,
                navigationRouter: NavigationRoutingProtocol,
                inject: CoreInjectionProtocol,
                environment: EnvironmentType,
                interestsRepository: F4SInterestsRepositoryProtocol) {
        self.applyCoordinatorDelegate = applyCoordinatorDelegate
        self.applyService = applyService
        self.environment = environment
        self.startingViewController = navigationRouter.navigationController.topViewController
        self.interestsRepository = interestsRepository
        self.companyWorkplace = companyWorkplace
        self.association = association
        super.init(parent: parent, navigationRouter: navigationRouter, inject: inject)
        self.draftPlacement.associationUuid = association.uuid
    }
    
    override public func start() {
        super.start()
        startDateOfBirthIfNecessary()
    }
    
    func startDateOfBirthIfNecessary() {
        guard let dateOfBirth = userRepository.loadCandidate().dateOfBirth,
            let dateString = Date.workfinderDateStringToDate(dateOfBirth)
            else {
            let dobVC = DateOfBirthCollectorViewController(coordinator: self)
            navigationRouter.push(viewController: dobVC, animated: true)
            return
        }
        onDidSelectDataOfBirth(date: dateString)
    }
    
    func startCoverLetterCoordinator(candidateDateOfBirth: Date) {
        guard let hostName = association.host.displayName else { return }
        let candidateName = injected.user.fullName
        let companyName = companyWorkplace.companyJson.name ?? "Unknown company"
        coverletterCoordinator = CoverLetterCoordinator(parent: self,
                                                        navigationRouter: navigationRouter,
                                                        inject: injected,
                                                        candidateDateOfBirth: candidateDateOfBirth,
                                                        candidateName: candidateName,
                                                        companyName: companyName,
                                                        hostName: hostName)
        coverletterCoordinator?.start()
    }
    
    func startSigninCoordinatorIfNecessary() {
        guard isUserRegistrationWorkflowRequired
            else {
            onCandidateIsSignedIn()
            return
        }
        let coordinator = RegisterAndSignInCoordinator(parent: self, navigationRouter: navigationRouter, inject: injected)
        addChildCoordinator(coordinator)
        coordinator.start()
    }
    
    func coverLetterCoordinatorDidComplete(presenter: CoverLetterViewPresenterProtocol) {
        draftPlacement.coverLetterString = presenter.displayString
        startSigninCoordinatorIfNecessary()
    }
    
    deinit { print("ApplyCoordinator did deinit") }
}

extension ApplyCoordinator: RegisterAndSignInCoordinatorParent {
    
    func onCandidateIsSignedIn() {
        submitApplication()
    }
    
    func submitApplication() {
        let navigationController = navigationRouter.navigationController
        guard let messageHandler = coverletterCoordinator?.messageHandler
            else { return }
        let draft = prepareDraftPlacement()
        applicationSubmitter = ApplicationSubmitter(
            applyService: applyService,
            draft: draft,
            navigationController: navigationController,
            messageHandler: messageHandler,
            onSuccess: self.showApplicationSubmittedSuccessfully,
            onCancel: { self.cancelButtonWasTapped(sender: self) })
        applicationSubmitter?.submitApplication()
    }
    
    func prepareDraftPlacement() -> Placement {
        draftPlacement.candidateUuid = userRepository.loadCandidate().uuid!
        return draftPlacement
    }
}

public class ApplicationSubmitter {
    private var draft: Placement
    private let applyService: PostPlacementServiceProtocol
    private weak var navigationController: UINavigationController?
    private var onSuccess: () -> Void
    private var onCancel: () -> Void
    private weak var messageHandler: UserMessageHandler?
    
    init(
        applyService: PostPlacementServiceProtocol,
        draft: Placement,
        navigationController: UINavigationController,
        messageHandler: UserMessageHandler,
        onSuccess: @escaping () -> Void,
        onCancel: @escaping () -> Void) {
        self.applyService = applyService
        self.draft = draft
        self.navigationController = navigationController
        self.messageHandler = messageHandler
        self.onSuccess = onSuccess
        self.onCancel = onCancel
    }
    
    public func submitApplication() {
        applyService.postPlacement(draftPlacement: draft) { [weak self] (result) in
            guard
                let self = self,
                let messageHandler =  self.messageHandler
                else { return }
            switch result {
            case .success(_): self.onSuccess()
            case .failure(let error):
                messageHandler.displayOptionalErrorIfNotNil(
                    error,
                    cancelHandler: self.onCancel,
                    retryHandler: self.submitApplication)
            }
        }
    }
}

extension ApplyCoordinator {
    
    func cancelAfterUserDetails() {
        let alert = UIAlertController(title: "Already applied", message: "You have already applied to this company (perhaps on a different device", preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { [weak self] (action) in
            guard let strongSelf = self else { return }
            strongSelf.navigationRouter.popToViewController(strongSelf.rootViewController!, animated: false)
            strongSelf.applyCoordinatorDelegate?.applicationDidCancel()
            strongSelf.parentCoordinator?.childCoordinatorDidFinish(strongSelf)
        }
        alert.addAction(okAction)
        navigationRouter.present(alert, animated: true, completion: nil)
    }
    
    func cancelButtonWasTapped(sender: Any?) {
        cleanup()
        navigationRouter.pop(animated: true)
        parentCoordinator?.childCoordinatorDidFinish(self)
    }
    
    func cleanup(animated: Bool = true) {
        childCoordinators = [:]
    }

}

extension ApplyCoordinator: DateOfBirthCoordinatorProtocol {
    
    func onDidCancel() {
    }
    
    func onDidSelectDataOfBirth(date: Date) {
        var candidate = userRepository.loadCandidate()
        candidate.dateOfBirth = date.workfinderDateString
        userRepository.save(candidate: candidate)
        startCoverLetterCoordinator(candidateDateOfBirth: date)
    }
}
