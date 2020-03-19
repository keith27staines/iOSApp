
import Foundation
import WorkfinderCommon
import WorkfinderAppLogic
import WorkfinderUI
import WorkfinderCoordinators
import WorkfinderDocumentUploadUseCase
import WorkfinderUserDetailsUseCase

let __bundle = Bundle(identifier: "com.f4s.WorkfinderApplyUseCase")!

public protocol ApplyCoordinatorDelegate : class {
    func applicationDidFinish(preferredDestination: ApplyCoordinator.PreferredDestinationAfterApplication)
    func applicationDidCancel()
}

public protocol ApplyServiceProtocol {}
public class ApplyService: ApplyServiceProtocol {
    
}

public class ApplyCoordinator : CoreInjectionNavigationCoordinator {
    
    public enum PreferredDestinationAfterApplication {
        case messages
        case search
        case none
    }
    let environment: EnvironmentType
    var applicationContext: F4SApplicationContext
    var templateService: F4STemplateServiceProtocol
    var interestsRepository: F4SInterestsRepositoryProtocol
    let emailVerificationModel: F4SEmailVerificationModelProtocol
    let startingViewController: UIViewController!
    let documentUploaderFactory: F4SDocumentUploaderFactoryProtocol
    let applyService: ApplyServiceProtocol
    weak var applyCoordinatorDelegate: ApplyCoordinatorDelegate?
    lazy var userInterests: [F4SInterest] = { return interestsRepository.loadInterestsArray() }()
    
    lazy var applicationModel: ApplicationModelProtocol = {
        let applicationContext = F4SApplicationContext()
        return ApplicationModel(
            applicationContext: self.applicationContext,
            templateService: templateService)
    }()
    
    public init(applyCoordinatorDelegate: ApplyCoordinatorDelegate? = nil,
                applyService: ApplyServiceProtocol,
                companyWorkplace: CompanyWorkplace,
                host: F4SHost? = nil,
                parent: CoreInjectionNavigationCoordinator?,
                navigationRouter: NavigationRoutingProtocol,
                inject: CoreInjectionProtocol,
                environment: EnvironmentType,
                templateService: F4STemplateServiceProtocol,
                interestsRepository: F4SInterestsRepositoryProtocol,
                emailVerificationModel: F4SEmailVerificationModelProtocol,
                documentServiceFactory: F4SPlacementDocumentsServiceFactoryProtocol,
                documentUploaderFactory: F4SDocumentUploaderFactoryProtocol) {
        self.applyCoordinatorDelegate = applyCoordinatorDelegate
        self.applyService = applyService
        self.applicationContext = F4SApplicationContext(user: inject.user, companyWorkplace: companyWorkplace, host: host)
        self.environment = environment
        self.templateService = templateService
        self.startingViewController = navigationRouter.navigationController.topViewController
        self.interestsRepository = interestsRepository
        self.emailVerificationModel = emailVerificationModel
        self.documentUploaderFactory = documentUploaderFactory
        super.init(parent: parent, navigationRouter: navigationRouter, inject: inject)
    }
    
    override public func start() {
        super.start()
        showApplicationLetterViewController()
    }
    
    var rootViewController: UIViewController?
    
    func showApplicationLetterViewController() {
        let applicationLetterViewModel = applicationModel.applicationLetterViewModel
        let applicationLetterViewController = ApplicationLetterViewController(coordinator: self, viewModel: applicationLetterViewModel)
        applicationLetterViewController.log = injected.log
        rootViewController = applicationLetterViewController
        navigationRouter.push(viewController: applicationLetterViewController, animated: true)
    }
    
    func showApplicationLetterEditor() {
        let coverLetterStoryboard = UIStoryboard(name: "EditCoverLetter", bundle: __bundle)
        let editor = coverLetterStoryboard.instantiateViewController(withIdentifier: "EditCoverLetterCtrl") as! EditCoverLetterViewController
        editor.coordinator = self
        editor.log = injected.log
        editor.suppressMotivationField = (injected.user.age() ?? 0) < 18 ? true : false
        editor.blanksModel = applicationModel.blanksModel
        editor.motivationTextModel = applicationModel.motivationTextModel
        editor.availabilityPeriodJson = applicationModel.availabilityPeriodJson
        navigationRouter.push(viewController: editor, animated: true)
    }
    
    func showChooseValuesForBlank(name: TemplateBlankName, inTemplate template: F4STemplate) {
        let storyboard = UIStoryboard(name: "ChooseAttributes", bundle: __bundle)
        let vc = storyboard.instantiateViewController(withIdentifier: "ChooseAttributesCtrl") as! ChooseAttributesViewController
        let model = applicationModel.applicationLetterModel.blanksModel
        let viewModel = ChooseAttributesViewModel(model: model, chooseValuesFor: name)
        viewModel.coordinator = self
        vc.coordinator = self
        vc.viewModel = viewModel
        navigationRouter.push(viewController: vc, animated: true)
    }
    
    deinit {
        print("ApplyCoordinator did deinit")
    }
}

extension ApplyCoordinator : ApplicationLetterViewControllerCoordinating {
    
    func continueApplicationWithCompletedLetter(sender: Any?, completion: @escaping (Error?) -> Void) {
        showUserDetails()
        completion(nil)
    }
    
    func showUserDetails() {
        
        let userDetailsCoordinator = UserDetailsCoordinator(
            parent: self,
            navigationRouter: navigationRouter,
            inject: injected,
            emailVerificationModel: emailVerificationModel,
            environment: environment)
        
        userDetailsCoordinator.didFinish = { [weak self] coordinator in
            self?.userDetailsDidFinish()
        }
        
        userDetailsCoordinator.userIsTooYoung = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.cleanup()
            strongSelf.navigationRouter.navigationController.popToRootViewController(animated: false)
            strongSelf.parentCoordinator?.childCoordinatorDidFinish(strongSelf)
        }
        
        addChildCoordinator(userDetailsCoordinator)
        userDetailsCoordinator.start()
    }
    
    func userDetailsDidFinish() {
        let user = injected.userRepository.load()
        applicationContext.user = user
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
        applicationModel.createApplication { [weak self] (error) in
            self?.applyDidComplete(error: error)
        }
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
    
    func editButtonWasTapped(sender: Any?) {
        showApplicationLetterEditor()
    }
}

extension ApplyCoordinator : EditCoverLetterViewControllerCoordinatorProtocol {
    func editCoverLetterViewControllerDidCancel() {
        navigationRouter.pop(animated: true)
    }
    
    func editCoverLetterViewControllerDidFinish(_ viewController: EditCoverLetterViewController) {
        self.applicationModel.availabilityPeriodJson = viewController.availabilityPeriodJson
        navigationRouter.pop(animated: true)
        applicationModel.applicationLetterModel.render()
    }
    
    func chooseValuesForTemplateBlank(name: TemplateBlankName, inTemplate template: F4STemplate) {
        showChooseValuesForBlank(name: name, inTemplate: template)
    }
}

extension ApplyCoordinator : ChooseAttributesViewControllerCoordinatorProtocol {
    func chooseAttributesViewControllerDidFinish() {
        navigationRouter.pop(animated: true)
    }
    
    func chooseAttributesViewControllerDidCancel() {
        navigationRouter.pop(animated: true)
    }
}
