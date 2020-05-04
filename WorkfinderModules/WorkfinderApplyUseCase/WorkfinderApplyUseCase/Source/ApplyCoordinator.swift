
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
            self?.applyCoordinatorDelegate?.applicationDidFinish(preferredDestination: .messages)
        }) { [weak self] in
            self?.removeApplicationSubmittedSuccessfully()
            self?.applyCoordinatorDelegate?.applicationDidFinish(preferredDestination: .search)
        }
    }()
    
    var isUserRegistrationWorkflowRequired: Bool {
        let userRepository = injected.userRepository
        let candidate = userRepository.loadCandidate()
        return candidate.uuid == nil
    }
    
    let association: HostLocationAssociationJson
    
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
        self.association = association
        super.init(parent: parent, navigationRouter: navigationRouter, inject: inject)
        self.draftPlacement.associationUuid = association.uuid
    }
    
    override public func start() {
        super.start()
        startDateOfBirthIfNecessary()
        //startSigninCoordinatorIfNecessary()
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
        coverletterCoordinator = CoverLetterCoordinator(parent: self, navigationRouter: navigationRouter, inject: injected, candidateDateOfBirth: candidateDateOfBirth)
        coverletterCoordinator?.start()
    }
    
    func startSigninCoordinatorIfNecessary() {
        guard isUserRegistrationWorkflowRequired
            else {
            onDidRegister()
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
    
    func onDidRegister(pop: Bool = true) {
        draftPlacement.candidateUuid = userRepository.loadCandidate().uuid!
        applyService.postPlacement(draftPlacement: draftPlacement) {
            [weak self] (result) in
            switch result {
            case .success(let placement):
                self?.showApplicationSubmittedSuccessfully()
            case .failure(let error):
                break
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
    
    func showApplicationSubmittedSuccessfully() {
        guard let window = UIApplication.shared.keyWindow else { return }
        window.addSubview(successPopup)
        let navigationController = navigationRouter.navigationController
        navigationController.navigationBar.layer.zPosition = -1
        successPopup.frame = window.bounds
    }
    
    func removeApplicationSubmittedSuccessfully() {
        successPopup.removeFromSuperview()
        let navigationController = navigationRouter.navigationController
        navigationController.navigationBar.layer.zPosition = 0
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
