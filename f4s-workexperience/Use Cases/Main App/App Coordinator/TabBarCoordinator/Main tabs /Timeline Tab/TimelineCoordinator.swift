//
//  TimelineCoordinator.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 02/03/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation
import WorkfinderCommon

class TimelineCoordinator : CoreInjectionNavigationCoordinator {
    
    lazy var rootViewController: TimelineViewController = {
        let storyboard = UIStoryboard(name: "TimelineView", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "timelineViewCtrl") as! TimelineViewController
    }()
    
    override func start() {
        rootViewController.coordinator = self
        navigationRouter.navigationController.pushViewController(rootViewController, animated: false)
    }
    
    func showThread(_ thread: F4SUUID?) {
        guard let thread = thread else { return }
        rootViewController.threadUuid = thread
        //rootViewController.goToMessageViewCtrl()
    }
    
    var company: Company?
    
    func showCompanyDetails(parentCtrl: UIViewController, company: Company) {
        self.company = company
        assert(parentCtrl.navigationController != nil)
        guard let navigationController = parentCtrl.navigationController else { return }
        let factory = CompanyCoordinatorFactory()
        let navigationRouter = NavigationRouter(navigationController: navigationController)
        let companyCoordinator = factory.makeCompanyCoordinator(parent: self, navigationRouter: navigationRouter, company: company, inject: injected)
        companyCoordinator.parentCoordinator = self
        addChildCoordinator(companyCoordinator)
        companyCoordinator.start()
    }
    
    func showMessageController(parentCtrl: UIViewController, threadUuid: String?, company: Company, placements: [F4STimelinePlacement], companies: [Company]) {
        let messageStoryboard = UIStoryboard(name: "Message", bundle: nil)
        guard let messageController = messageStoryboard.instantiateViewController(withIdentifier: "MessageContainerViewCtrl") as? MessageContainerViewController else {
            return
        }
        messageController.threadUuid = threadUuid
        messageController.company = company
        messageController.companies = companies
        messageController.placements = placements
        messageController.coordinator = self
        parentCtrl.navigationController?.pushViewController(messageController, animated: true)
    }
    
    func showAcceptOffer(acceptContext: AcceptOfferContext?) {
        guard let acceptContext = acceptContext else { return }
        let acceptCoordinator = AcceptOfferCoordinator(parent: self, navigationRouter: navigationRouter, inject: injected, acceptContext: acceptContext)
        addChildCoordinator(acceptCoordinator)
        acceptCoordinator.start()
    }
    
    func showAddDocuments(placement: F4STimelinePlacement?, company: Company?, action: F4SAction) {
        guard
            let placement = placement, let company = company,
            let requestModel = F4SBusinessLeadersRequestModel(action: action, placement: placement, company: company) else { return }
        let mode = F4SAddDocumentsViewController.Mode.businessLeaderRequest(requestModel)
        let coordinator = DocumentUploadCoordinator(parent: self, navigationRouter: navigationRouter, inject: injected, mode: mode, applicationContext: nil)
        coordinator.didFinish = { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.navigationRouter.popToViewController(strongSelf.rootViewController, animated: true)
            print("What is supposed to happen here?")
        }
        addChildCoordinator(coordinator)
        coordinator.start()
    }
    
    func showExternalCompanySite(urlString: String?, acceptContext: AcceptOfferContext?) {
        guard
            let urlString = urlString,
            let url = URL(string: urlString),
            let acceptContext = acceptContext else {
                globalLog.error("Unable to open the company's external application page")
                return
        }
        UIApplication.shared.open(url, options: [:]) { (success) in
            var event = F4SAnalyticsEvent(name: .viewCompanyExternalApplication)
            event.addProperty(name: "placement_uuid", value: acceptContext.placement.placementUuid ?? "")
            event.addProperty(name: "company_name", value: acceptContext.company.name)
            event.track()
        }
    }
}
