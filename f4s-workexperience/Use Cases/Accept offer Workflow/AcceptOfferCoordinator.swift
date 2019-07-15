//
//  AcceptOfferCoordinator.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 25/05/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation

class AcceptOfferCoordinator : CoreInjectionNavigationCoordinator {
    
    let acceptContext: AcceptOfferContext
    let parent: CoreInjectionNavigationCoordinator
    
    init(parent: CoreInjectionNavigationCoordinator,
         navigationRouter: NavigationRoutingProtocol,
         inject: CoreInjectionProtocol,
         acceptContext: AcceptOfferContext) {
        self.parent = parent
        self.acceptContext = acceptContext
        super.init(parent: parent, navigationRouter: navigationRouter, inject: inject)
    }
    
    override func start() {
        let acceptStoryboard = UIStoryboard(name: "AcceptOffer", bundle: nil)
        let vc = acceptStoryboard.instantiateInitialViewController() as! AcceptOfferViewController
        vc.accept = acceptContext
        vc.coordinator = self
        navigationRouter.push(viewController: vc, animated: true)
    }
    
    func showCompanyDetail(company: Company) {
        let companyCoordinator = CompanyCoordinator(parent: parent, navigationRouter: navigationRouter, company: company, inject: injected)
        addChildCoordinator(companyCoordinator)
        companyCoordinator.start()
    }
    
    func didDecline() {
        navigationRouter.pop(animated: true)
        parentCoordinator?.childCoordinatorDidFinish(self)
    }
    
    func didCancel() {
        navigationRouter.pop(animated: true)
        parentCoordinator?.childCoordinatorDidFinish(self)
    }
    
}
