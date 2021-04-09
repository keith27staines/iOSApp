//
//  AccountCoordinator.swift
//  WorkfinderCandidateProfile
//
//  Created by Keith Staines on 08/04/2021.
//

import WorkfinderCommon
import WorkfinderServices
import WorkfinderCoordinators

public class AccountCoordinator: CoreInjectionNavigationCoordinator {
    var switchToTab: ((TabIndex) -> Void)?
    
    public init(
        parent: Coordinating?,
        navigationRouter: NavigationRoutingProtocol,
        inject: CoreInjectionProtocol,
        switchToTab: ((TabIndex) -> Void)?
    ) {
        self.switchToTab = switchToTab
        super.init(parent: parent, navigationRouter: navigationRouter, inject: inject)
    }
    
    public override func start() {
        let vc = AccountViewController(coordinator: self)
        navigationRouter.push(viewController: vc, animated: true)
    }
}
