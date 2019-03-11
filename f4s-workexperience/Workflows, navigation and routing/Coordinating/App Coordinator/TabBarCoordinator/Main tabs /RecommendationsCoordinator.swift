//
//  RecommendationsCoordinator.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 28/02/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation

class RecommendationsCoordinator : CoreInjectionNavigationCoordinator {
    
    lazy var rootViewController: RecommendationsViewController = {
        let storyboard = UIStoryboard(name: "Recommendations", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "RecommendationsViewController") as! RecommendationsViewController
    }()
    
    override func start() {
        rootViewController.coordinator = self
        navigationRouter.navigationController.pushViewController(rootViewController, animated: false)
    }
    
    func showDetail(company: Company?) {
        guard let company = company else { return }
        let companyCoordinator = CompanyCoordinator(parent: self, navigationRouter: navigationRouter, company: company)
        addChildCoordinator(companyCoordinator)
        companyCoordinator.start()
    }
    
}


