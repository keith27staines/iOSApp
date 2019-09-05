import Foundation
import WorkfinderCommon
import WorkfinderServices
import WorkfinderAppLogic
import WorkfinderUI
import WorkfinderCoordinators
import WorkfinderUserDetailsUseCase

let __bundle = Bundle(identifier: "com.f4s.WorkfinderApplyUseCase")!

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
    
    var applicationContext: F4SApplicationContext
    var createPlacementJson: F4SCreatePlacementJson?
    var placementService: F4SPlacementApplicationServiceProtocol
    var templateService: F4STemplateServiceProtocol
    var placementRepository: F4SPlacementRepositoryProtocol
    var interestsRepository: F4SInterestsRepositoryProtocol
    let startingViewController: UIViewController!
    weak var applyCoordinatorDelegate: ApplyCoordinatorDelegate?
    lazy var userInterests: [F4SInterest] = {
        return interestsRepository.loadUserInterests()
    }()
    
    lazy var applicationModel: ApplicationModelProtocol = {
        let userUuid = injected.user.uuid!
        let installationUuid = injected.appInstallationUuidLogic.registeredInstallationUuid!
        let companyViewData = CompanyViewData(company: applicationContext.company!)
        let placement = applicationContext.placement
        return ApplicationModel(userUuid: userUuid, installationUuid: installationUuid, userInterests: userInterests, placement: placement, placementRepository: placementRepository, companyViewData: companyViewData, placementService: placementService, templateService: templateService)
    }()
    
    init(applyCoordinatorDelegate: ApplyCoordinatorDelegate? = nil,
         company: Company,
         parent: CoreInjectionNavigationCoordinator?,
         navigationRouter: NavigationRoutingProtocol,
         inject: CoreInjectionProtocol,
         placementService: F4SPlacementApplicationServiceProtocol,
         templateService: F4STemplateServiceProtocol,
         placementRepository: F4SPlacementRepositoryProtocol,
         interestsRepository: F4SInterestsRepositoryProtocol) {
        self.applyCoordinatorDelegate = applyCoordinatorDelegate
        self.applicationContext = F4SApplicationContext(user: F4SUser(), company: company, placement: nil)
        self.placementService = placementService
        self.templateService = templateService
        self.startingViewController = navigationRouter.navigationController.topViewController
        self.placementRepository = placementRepository
        self.interestsRepository = interestsRepository
        super.init(parent: parent, navigationRouter: navigationRouter, inject: inject)
    }
    
    override public func start() {
        super.start()
        showApplicationLetterViewController()
    }
    
    var rootViewController: UIViewController?
    
    lazy var canApplyLogic: AllowedToApplyLogic = {
        return AllowedToApplyLogic()
    }()
    
    func showApplicationLetterViewController() {
        let applicationLetterViewModel = applicationModel.applicationLetterViewModel
        let applicationLetterViewController = ApplicationLetterViewController(coordinator: self, viewModel: applicationLetterViewModel)
        rootViewController = applicationLetterViewController
        navigationRouter.push(viewController: applicationLetterViewController, animated: true)
    }
    
    func showApplicationLetterEditor() {
        let coverLetterStoryboard = UIStoryboard(name: "EditCoverLetter", bundle: bundle)
        let editor = coverLetterStoryboard.instantiateViewController(withIdentifier: "EditCoverLetterCtrl") as! EditCoverLetterViewController
        editor.coordinator = self
        editor.blanksModel = applicationModel.blanksModel
        editor.availabilityPeriodJson = applicationModel.availabilityPeriodJson
        navigationRouter.push(viewController: editor, animated: true)
    }
    
    func showChooseValuesForBlank(name: TemplateBlankName, inTemplate template: F4STemplate) {
        let storyboard = UIStoryboard(name: "ChooseAttributes", bundle: nil)
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
        
        let userDetailsCoordinator = UserDetailsCoordinator(parent: self, navigationRouter: navigationRouter, inject: injected)
        
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
        let companyUuid = applicationContext.company!.uuid
        canApplyLogic.checkUserCanApply(user: "", to: companyUuid) { [weak self] (networkResult) in
            guard let strongSelf = self else { return }
            switch networkResult {
            case .error(let error):
                let topViewController = strongSelf.navigationRouter.navigationController.topViewController!
                sharedUserMessageHandler.display(error, parentCtrl: topViewController, cancelHandler: {
                    strongSelf.cancelAfterUserDetails()
                }, retryHandler: {
                    strongSelf.checkApplicationCanProceed()
                })
            case .success(true):
                strongSelf.apply()
            case .success(false):
                strongSelf.cancelAfterUserDetails()
            }
        }
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
        if let draft = canApplyLogic.draftPlacement {
            applicationModel.resumeApplicationFromPreexistingDraft(draft) { [weak self] (error) in
                self?.applyDidComplete(error: error)
            }
        } else {
            applicationModel.createApplication { [weak self] (error) in
                self?.applyDidComplete(error: error)
            }
        }
    }
    
    func applyDidComplete(error: Error?) {
        guard error == nil else { return }
        applicationContext.placement = applicationModel.placement
        showAddDocuments()
    }
    
    func showAddDocuments() {
        let coordinator = DocumentUploadCoordinator(parent: self, navigationRouter: navigationRouter, inject: injected, mode: F4SAddDocumentsViewController.Mode.applyWorkflow, applicationContext: applicationContext)
        coordinator.didFinish = { [weak self] coordinator in
            guard let strongSelf = self else { return }
            strongSelf.navigationRouter.pop(animated: false)
            strongSelf.addDocumentsDidFinish()
        }
        addChildCoordinator(coordinator)
        coordinator.start()
    }
    
    func addDocumentsDidFinish() {
        showApplicationSubmittedSuccessfully()
    }
    
    func showApplicationSubmittedSuccessfully() {
        navigationRouter.popToViewController(startingViewController, animated: false)
        let successViewController = UIStoryboard(name: "SuccessExtraInfo", bundle: applyBundle).instantiateViewController(withIdentifier: "SuccessExtraInfoCtrl") as! SuccessExtraInfoViewController
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
