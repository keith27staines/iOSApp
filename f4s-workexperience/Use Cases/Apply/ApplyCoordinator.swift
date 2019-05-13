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

protocol ApplyCoordinatorCoordinating : Coordinating {
    func continueApplicationFromPlacementInAppliedState(_ placementJson: WEXPlacementJson, takingOverFrom coordinator: Coordinating)
}

class ApplyCoordinator : CoreInjectionNavigationCoordinator {
    
    let companyViewData: CompanyViewData
    var placement: F4SPlacement?
    var createPlacementJson: WEXCreatePlacementJson?
    var createPlacementServiceFactory: WEXPlacementServiceFactoryProtocol?
    var placementService: WEXPlacementServiceProtocol
    var templateService: F4STemplateServiceProtocol
    var placementRepository: F4SPlacementRepositoryProtocol = F4SPlacementRespository()
    var interestsRepository: F4SInterestsRepositoryProtocol = F4SInterestsRepository()
    
    lazy var userInterests: [F4SInterest] = {
        return interestsRepository.loadUserInterests()
    }()
    
    lazy var applicationModel: ApplicationModelProtocol = {
        let userUuid = injected.user.uuid!
        let installationUuid = injected.installationUuid
        return ApplicationModel(userUuid: userUuid, installationUuid: installationUuid, userInterests: userInterests, placement: placement, placementRepository: placementRepository, companyViewData: companyViewData, placementService: placementService, templateService: templateService)
    }()
    
    var continueFromTimelinePlacement: F4STimelinePlacement?
    
    init(company: CompanyViewData,
         placement: F4SPlacement?,
         parent: ApplyCoordinatorCoordinating?,
         navigationRouter: NavigationRoutingProtocol,
         inject: CoreInjectionProtocol,
         placementService: WEXPlacementServiceProtocol,
         templateService: F4STemplateServiceProtocol,
         continueFrom: F4STimelinePlacement? = nil) {
        self.companyViewData = company
        self.placementService = placementService
        self.templateService = templateService
        self.continueFromTimelinePlacement = continueFrom
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
}

extension ApplyCoordinator : ApplicationLetterViewControllerCoordinating {
    func continueApplicationWithCompletedLetter(sender: Any?, completion: @escaping (Error?) -> Void) {
        applicationModel.createApplicationIfNecessary { [weak self] (error) in
            guard let strongSelf = self else { return }
            if let error = error {
                completion(error)
                return
            }
            let parentCoordinator = strongSelf.parentCoordinator as! ApplyCoordinatorCoordinating
            let placement = strongSelf.applicationModel.placementJson!
            strongSelf.cleanup(animated: false)
            parentCoordinator.continueApplicationFromPlacementInAppliedState(placement, takingOverFrom: strongSelf)
            completion(nil)
            parentCoordinator.childCoordinatorDidFinish(strongSelf)
        }
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
