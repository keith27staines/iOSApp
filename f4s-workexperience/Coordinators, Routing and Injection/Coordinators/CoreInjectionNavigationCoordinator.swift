//
//  CoreInjectionNavigationCoordinator.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 28/02/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation
import WorkfinderCommon

protocol CoreInjectionNavigationCoordinatorProtocol : Coordinating {
    var injected: CoreInjectionProtocol { get }
}

/// A suitable base class for coordinators representing tabs on a tabbar
class CoreInjectionNavigationCoordinator : NavigationCoordinator {
    let injected: CoreInjectionProtocol
    init(parent: Coordinating?, navigationRouter: NavigationRoutingProtocol, inject: CoreInjectionProtocol) {
        injected = inject
        super.init(parent: parent, navigationRouter: navigationRouter)
    }
    
    func presentContent(_ contentType: F4SContentType) {
        let storyboard = UIStoryboard(name: "Content", bundle: nil)
        let contentViewController = storyboard.instantiateViewController(withIdentifier: "ContentViewCtrl") as! ContentViewController
        contentViewController.contentType = contentType
        contentViewController.dismissByPopping = true
        navigationRouter.navigationController.pushViewController(contentViewController, animated: true)
    }
}

extension CoreInjectionNavigationCoordinator : CoreInjectionNavigationCoordinatorProtocol {}
