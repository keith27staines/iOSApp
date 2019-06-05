//
//  FavouritesCoordinator.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 02/03/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation
import WorkfinderCommon

class FavouritesCoordinator : CoreInjectionNavigationCoordinator {
    
    lazy var rootViewController: FavouriteViewController = {
        let storyboard = UIStoryboard(name: "Favourite", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "FavouriteViewCtrl") as! FavouriteViewController
    }()
    
    override func start() {
        rootViewController.coordinator = self
        navigationRouter.navigationController.pushViewController(rootViewController, animated: false)
    }
    
    var company: Company?
    
    func showDetail(company: Company?) {
        self.company = company
        guard let company = company else { return }
        rootViewController.dismiss(animated: true)
        let companyCoordinator = CompanyCoordinator(parent: self, navigationRouter: navigationRouter, company: company, inject: injected)
        addChildCoordinator(companyCoordinator)
        companyCoordinator.start()
    }
}
