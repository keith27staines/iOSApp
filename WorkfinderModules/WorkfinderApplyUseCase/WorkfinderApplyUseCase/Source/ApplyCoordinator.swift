
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
    func applicationDidFinish(preferredDestination: ApplyCoordinator.PreferredDestinationAfterApplication)
    func applicationDidCancel()
}

public class ApplyCoordinator : CoreInjectionNavigationCoordinator {
    
    public enum PreferredDestinationAfterApplication {
        case messages
        case search
        case none
    }
    var coverletterCoordinator: CoverletterCoordinatorProtocol?
    var rootViewController: UIViewController?
    let environment: EnvironmentType
    var interestsRepository: F4SInterestsRepositoryProtocol
    let startingViewController: UIViewController!
    let applyService: ApplyServiceProtocol
    weak var applyCoordinatorDelegate: ApplyCoordinatorDelegate?
    lazy var userInterests: [F4SInterest] = { return interestsRepository.loadInterestsArray() }()
    
    lazy var applicationModel: ApplicationModel = {
        return ApplicationModel()
    }()
    
    public init(applyCoordinatorDelegate: ApplyCoordinatorDelegate? = nil,
                applyService: ApplyServiceProtocol,
                companyWorkplace: CompanyWorkplace,
                association: HostLocationAssociationJson? = nil,
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
        super.init(parent: parent, navigationRouter: navigationRouter, inject: inject)
    }
    
    override public func start() {
        super.start()
        startDateOfBirth()
    }
    
    func startSigninCoordinator() {
        let coordinator = RegisterAndSignInCoordinator(parent: self, navigationRouter: navigationRouter, inject: injected)
        addChildCoordinator(coordinator)
        coordinator.start()
    }
    
    func startDateOfBirth() {
        let dobVC = DateOfBirthCollectorViewController(coordinator: self)
        navigationRouter.push(viewController: dobVC, animated: true)
    }
    
    func startCoverLetterCoordinator(candidateDateOfBirth: Date) {
        coverletterCoordinator = CoverLetterCoordinator(parent: self, navigationRouter: navigationRouter, inject: injected, candidateDateOfBirth: candidateDateOfBirth)
        coverletterCoordinator?.start()
    }
    
    func coverLetterCoordinatorDidComplete(presenter: CoverLetterViewPresenterProtocol) {
        startSigninCoordinator()
    }
    
    deinit { print("ApplyCoordinator did deinit") }
}

extension ApplyCoordinator: RegisterAndSignInCoordinatorParent {
    func onDidRegister(user: User, pop: Bool = true) {
        if pop { navigationRouter.pop(animated: true) }
        
    }
}

extension ApplyCoordinator {
    
    func showUserDetails() {
        
    }
    
    func userDetailsDidFinish() {
        checkApplicationCanProceed()
    }
    
    func checkApplicationCanProceed() {
        // If can apply then do this...
        apply()
        return
        
        // If can't apply then do this...
        // cancelAfterUserDetails()
        
        // If we need a network call to determine then do something like this
        
//        let companyUuid = applicationContext.company!.uuid
//        canApplyLogic.checkUserCanApply(user: "", to: companyUuid) { [weak self] (networkResult) in
//            guard let strongSelf = self else { return }
//            switch networkResult {
//            case .error(let error):
//                let topViewController = strongSelf.navigationRouter.navigationController.topViewController!
//                sharedUserMessageHandler.display(error, parentCtrl: topViewController, cancelHandler: {
//                    strongSelf.cancelAfterUserDetails()
//                }, retryHandler: {
//                    strongSelf.checkApplicationCanProceed()
//                })
//            case .success(true):
//                strongSelf.apply()
//            case .success(false):
//                strongSelf.cancelAfterUserDetails()
//            }
//        }
    }
    
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
    
    func apply() {

    }
    
    func applyDidComplete(error: Error?) {
        guard error == nil else { return }
        showAddDocuments()
    }
    
    func showAddDocuments() {
//        let documentService = documentServiceFactory.makePlacementDocumentsService(placementUuid: placementuuid)
//        let coordinator = DocumentUploadCoordinator(
//            parent: self,
//            navigationRouter: navigationRouter,
//            inject: injected,
//            mode: .applyWorkflow,
//            documentService: documentService,
//            documentUploaderFactory: documentUploaderFactory)
//        coordinator.didFinish = { [weak self] coordinator in
//            guard let strongSelf = self else { return }
//            strongSelf.navigationRouter.pop(animated: false)
//            strongSelf.addDocumentsDidFinish()
//        }
//        addChildCoordinator(coordinator)
//        coordinator.start()
    }
    
    func addDocumentsDidFinish() {
        showApplicationSubmittedSuccessfully()
    }
    
    func showApplicationSubmittedSuccessfully() {
        navigationRouter.popToViewController(startingViewController, animated: false)
        let successViewController = UIStoryboard(name: "SuccessExtraInfo", bundle: __bundle).instantiateViewController(withIdentifier: "SuccessExtraInfoCtrl") as! SuccessExtraInfoViewController
        successViewController.log = injected.log
        successViewController.timelineButtonWasTapped = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.applyCoordinatorDelegate?.applicationDidFinish(preferredDestination: .messages)
        }
        successViewController.searchButtonWasTapped = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.applyCoordinatorDelegate?.applicationDidFinish(preferredDestination: .search)
        }
        
        startingViewController.view.addSubview(successViewController.view)
        startingViewController.addChild(successViewController)
        successViewController.view.fillSuperview()
        successViewController.didMove(toParent: startingViewController)
        successViewController.view.backgroundColor = UIColor.init(white: 0, alpha: 0.6)
    }
    
    func cancelButtonWasTapped(sender: Any?) {
        cleanup()
        navigationRouter.pop(animated: true)
        parentCoordinator?.childCoordinatorDidFinish(self)
    }
    
    func cleanup(animated: Bool = true) {
        childCoordinators = [:]
    }
    
    func termsAndConditionsWasTapped(sender: Any?) {
        presentContent(F4SContentType.terms)
    }

}

extension ApplyCoordinator: DateOfBirthCoordinatorProtocol {
    
    func onDidCancel() {
        
    }
    
    func onDidSelectDataOfBirth(date: Date) {
        startCoverLetterCoordinator(candidateDateOfBirth: date)
    }
}
