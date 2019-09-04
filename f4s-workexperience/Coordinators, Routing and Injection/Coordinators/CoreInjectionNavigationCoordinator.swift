//
//  CoreInjectionNavigationCoordinator.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 28/02/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation
import WorkfinderCommon
import WorkfinderUI
import WorkfinderCoordinators

public protocol CoreInjectionNavigationCoordinatorProtocol : Coordinating {
    var injected: CoreInjectionProtocol { get }
}

/// A suitable base class for coordinators representing tabs on a tabbar
public class CoreInjectionNavigationCoordinator : NavigationCoordinator {
    public let injected: CoreInjectionProtocol
    var log: F4SAnalyticsAndDebugging { return injected.log }
    
    init(parent: Coordinating?, navigationRouter: NavigationRoutingProtocol, inject: CoreInjectionProtocol) {
        injected = inject
        super.init(parent: parent, navigationRouter: navigationRouter)
    }
    
    func presentContent(_ contentType: F4SContentType) {
        let contentViewController = WorkfinderUI().makeWebContentViewController(contentType: contentType, dismissByPopping: true)
        navigationRouter.navigationController.pushViewController(contentViewController, animated: true)
    }
}

extension CoreInjectionNavigationCoordinator : CoreInjectionNavigationCoordinatorProtocol {}
