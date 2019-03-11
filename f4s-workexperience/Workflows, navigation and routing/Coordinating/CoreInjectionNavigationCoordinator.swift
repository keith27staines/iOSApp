//
//  CoreInjectionNavigationCoordinator.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 28/02/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation


protocol CoreInjectionNavigationCoordinatorProtocol : Coordinating {
    init(parent: Coordinating?, navigationRouter: NavigationRoutingProtocol, inject: CoreInjectionProtocol)
}

/// A suitable base class for coordinators representing tabs on a tabbar
class CoreInjectionNavigationCoordinator : NavigationCoordinator {
    let injected: CoreInjectionProtocol
    required init(parent: Coordinating?, navigationRouter: NavigationRoutingProtocol, inject: CoreInjectionProtocol) {
        injected = inject
        super.init(parent: parent, navigationRouter: navigationRouter)
    }
}

extension CoreInjectionNavigationCoordinator : CoreInjectionNavigationCoordinatorProtocol {}
