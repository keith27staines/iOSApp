//
//  TimelineCoordinator.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 02/03/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation
import WorkfinderCommon
import WorkfinderCoordinators
import WorkfinderAcceptUseCase
import WorkfinderDocumentUploadUseCase

let __bundle = Bundle(identifier: "com.f4s.WorkfinderMessagesUseCase")!

public class TimelineCoordinator : CoreInjectionNavigationCoordinator, CompanyCoordinatorParentProtocol {
    
    var company: Company?
    let companyCoordinatorFactory: CompanyCoordinatorFactoryProtocol
    let companyRepository: F4SCompanyRepositoryProtocol
    weak var tabBarCoordinator: TabBarCoordinatorProtocol?
    
    lazy var rootViewController: TimelineViewController = {
        let storyboard = UIStoryboard(name: "TimelineView", bundle: __bundle)
        return storyboard.instantiateViewController(withIdentifier: "timelineViewCtrl") as! TimelineViewController
    }()
    
    public override func start() {
        rootViewController.coordinator = self
        rootViewController.companyRepository = companyRepository
        navigationRouter.navigationController.pushViewController(rootViewController, animated: false)
    }
    
    func showCompanyDetails(parentCtrl: UIViewController, company: Company) {
        self.company = company
        assert(parentCtrl.navigationController != nil)
        guard let navigationController = parentCtrl.navigationController else { return }
        let navigationRouter = NavigationRouter(navigationController: navigationController)
        let companyCoordinator = companyCoordinatorFactory.makeCompanyCoordinator(parent: self, navigationRouter: navigationRouter, company: company, inject: injected)
        companyCoordinator.parentCoordinator = self
        addChildCoordinator(companyCoordinator)
        companyCoordinator.start()
    }
    
    func showMessageController(parentCtrl: UIViewController, threadUuid: String?, company: Company, placements: [F4STimelinePlacement], companies: [Company]) {
        let messageStoryboard = UIStoryboard(name: "Message", bundle: __bundle)
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
        let acceptCoordinator = AcceptOfferCoordinator(parent: self, navigationRouter: navigationRouter, inject: injected, acceptContext: acceptContext, companyCoordinatorFactory: companyCoordinatorFactory)
        addChildCoordinator(acceptCoordinator)
        acceptCoordinator.start()
    }
    
    func showAddDocuments(placement: F4STimelinePlacement?, company: Company?, action: F4SAction) {
        guard
            let placement = placement,
            let placementUuid = placement.placementUuid,
            let company = company,
            let requestModel = F4SBusinessLeadersRequestModel(action: action, placement: placement, company: company) else { return }
        let mode = UploadScenario.businessLeaderRequest(requestModel)
        let coordinator = DocumentUploadCoordinator(parent: self, navigationRouter: navigationRouter, inject: injected, mode: mode, placementUuid: placementUuid)
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
                injected.log.debug("acceptContext should not be nil", functionName: #function, fileName: #file, lineNumber: #line)
                return
        }
        UIApplication.shared.open(url, options: [:]) { (success) in
            var event = F4SAnalyticsEvent(name: .viewCompanyExternalApplication)
            event.addProperty(name: "placement_uuid", value: acceptContext.placement.placementUuid ?? "")
            event.addProperty(name: "company_name", value: acceptContext.company.companyName)
            event.track()
        }
    }
    
    public init(parent: TabBarCoordinatorProtocol?,
                navigationRouter: NavigationRoutingProtocol,
                inject: CoreInjectionProtocol,
                companyCoordinatorFactory: CompanyCoordinatorFactoryProtocol,
                companyRepository: F4SCompanyRepositoryProtocol) {
        self.tabBarCoordinator = parent
        self.companyCoordinatorFactory = companyCoordinatorFactory
        self.companyRepository = companyRepository
        super.init(parent: parent, navigationRouter: navigationRouter, inject: inject)
    }
    
    public func updateUnreadCount(_ count: Int) {
        tabBarCoordinator?.updateUnreadMessagesCount(count)
    }
    
    public func showMessages() {
        tabBarCoordinator?.showMessages()
    }
    
    public func showSearch() {
        tabBarCoordinator?.showSearch()
    }
    
    func toggleMenu() {
        tabBarCoordinator?.toggleMenu(completion: nil)
    }
}


