//
//  TimelineCoordinator.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 02/03/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation

class TimelineCoordinator : CoreInjectionNavigationCoordinator {
    
    lazy var rootViewController: TimelineViewController = {
        let storyboard = UIStoryboard(name: "TimelineView", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "timelineViewCtrl") as! TimelineViewController
    }()
    
    override func start() {
        rootViewController.coordinator = self
        navigationRouter.navigationController.pushViewController(rootViewController, animated: false)
    }
    
    func show(thread: F4SUUID?) {
        guard let thread = thread else { return }
        rootViewController.threadUuid = thread
        rootViewController.goToMessageViewCtrl()
    }
    
    func showDetail(company: Company?) {
        guard let company = company else { return }
        rootViewController.dismiss(animated: true)
        let companyCoordinator = CompanyCoordinator(parent: self, navigationRouter: navigationRouter, company: company)
        addChildCoordinator(companyCoordinator)
        companyCoordinator.start()
    }
}
