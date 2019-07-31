//
//  ApplyCoordinator.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 14/03/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation
import WorkfinderCommon
import WorkfinderApplyUseCase

protocol ApplyCoordinatorDelegate : class {
    func applicationDidFinish(preferredDestination: ApplyCoordinator.PreferredDestinationAfterApplication)
}

class ApplyCoordinator : CoreInjectionNavigationCoordinator {
    
    enum PreferredDestinationAfterApplication {
        case messages
        case search
    }
    
    var applicationContext: F4SApplicationContext
    var createPlacementJson: WEXCreatePlacementJson?
    var createPlacementServiceFactory: WEXPlacementServiceFactoryProtocol?
    var placementService: WEXPlacementServiceProtocol
    var templateService: F4STemplateServiceProtocol
    var placementRepository: F4SPlacementRepositoryProtocol = F4SPlacementRespository()
    var interestsRepository: F4SInterestsRepositoryProtocol = F4SInterestsRepository()
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
    
    var continueFromTimelinePlacement: F4STimelinePlacement?
    let startingViewController: UIViewController!
    
    init(applyCoordinatorDelegate: ApplyCoordinatorDelegate? = nil,
         company: Company,
         placement: F4SPlacement?,
         parent: CoreInjectionNavigationCoordinator?,
         navigationRouter: NavigationRoutingProtocol,
         inject: CoreInjectionProtocol,
         placementService: WEXPlacementServiceProtocol,
         templateService: F4STemplateServiceProtocol,
         continueFrom: F4STimelinePlacement? = nil) {
        self.applyCoordinatorDelegate = applyCoordinatorDelegate
        self.applicationContext = F4SApplicationContext(user: F4SUser(), company: company, placement: placement)
        self.placementService = placementService
        self.templateService = templateService
        self.continueFromTimelinePlacement = continueFrom
        self.startingViewController = navigationRouter.navigationController.topViewController
        super.init(parent: parent, navigationRouter: navigationRouter, inject: inject)
    }
    
    override func start() {
        super.start()
        showApplicationLetterViewController()
    }
    var rootViewController: UIViewController?
    
    func showApplicationLetterViewController() {
        let applicationLetterViewModel = applicationModel.applicationLetterViewModel
        let applicationLetterViewController = ApplicationLetterViewController(coordinator: self, viewModel: applicationLetterViewModel)
        rootViewController = applicationLetterViewController
        navigationRouter.push(viewController: applicationLetterViewController, animated: true)
    }
    
    func showApplicationLetterEditor() {
        let coverLetterStoryboard = UIStoryboard(name: "EditCoverLetter", bundle: nil)
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
    
    func showHalfWayHooray() {
        let halfWayStoryboard = UIStoryboard(name: "HalfWayHooray", bundle: nil)
        let vc = halfWayStoryboard.instantiateViewController(withIdentifier: "HalfWayHoorayViewController") as! HalfWayHoorayViewController
        vc.companyViewData = CompanyViewData(company: applicationContext.company!)
        vc.coordinator = self
        navigationRouter.push(viewController: vc, animated: true)
    }
    
    func halfWayHoorayDidFinish() {
        navigationRouter.pop(animated: true)
        showUserDetails()
    }
    
    func showUserDetails() {
        
        let userDetailsCoordinator = UserDetailsCoordinator(parent: self, navigationRouter: navigationRouter, inject: injected, applicationContext: applicationContext)
        
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
        let user = F4SUser(userInformation: injected.userRepository.load())
        applicationContext.user = user
        applicationModel.voucherUuid = user.vouchers?.first
        applicationModel.createApplicationIfNecessary { [weak self] (error) in
            guard let strongSelf = self else { return }
            if let _ = error {
                return
            }
            strongSelf.applicationContext.placement = strongSelf.applicationModel.placement
            strongSelf.showAddDocuments()
        }
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
        let successViewController = UIStoryboard(name: "SuccessExtraInfo", bundle: nil).instantiateViewController(withIdentifier: "SuccessExtraInfoCtrl") as! SuccessExtraInfoViewController
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

extension ApplyCoordinator : HalfWayHoorayCoordinatorProtocol {}
