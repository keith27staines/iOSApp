//
//  AppCoordinator.swift
//  F4SPrototypes
//
//  Created by Keith Dev on 21/01/2019.
//  Copyright © 2019 Keith Staines. All rights reserved.
//

import UIKit

class AppCoordinator : BaseCoordinator {
    
    var window: UIWindow

    
    init() {
        let navController = UINavigationController()
        window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = navController
        super.init(rootViewController: navController)
        window.makeKeyAndVisible()
    }
    
    override func start() {
//        let homeScreenViewController = HomeScreenViewController(delegate: self)
//        self.homeScreenViewController = homeScreenViewController
//        rootViewController.show(homeScreenViewController, sender: self)
    }
    
    func showCompanyDetailCoordinator() {
//        let coordinator = CompanyCoordinator(rootViewController: rootViewController, company: <#Company#>)
//        addChildCoordinator(coordinator)
//        coordinator.start()
    }
    
    override init(rootViewController: UIViewController) {
        fatalError("init(rootViewController:) has not been implemented")
    }
}

//extension AppCoordinator : HomeScreenViewControllerDelegate {
//    func homeScreenDidSelectCompanyDetailPrototype(_: HomeScreenViewController) {
//        showCompanyDetailCoordinator()
//    }
//    
//    
//}

