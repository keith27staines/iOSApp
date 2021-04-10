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
        let service = AccountService(networkConfig: injected.networkConfig)
        let presenter = AccountPresenter(coordinator: self, accountService: service)
        let vc = AccountViewController(coordinator: self, presenter: presenter)
        navigationRouter.push(viewController: vc, animated: true)
    }
    
    func showPreferences() {
        let service = AccountService(networkConfig: injected.networkConfig)
        let presenter = PreferencesPresenter(coordinator: self, accountService: service)
        let vc = PreferencesViewController(coordinator: self, presenter: presenter)
        navigationRouter.push(viewController: vc, animated: true)
    }
    
    func showDetails() {
        let service = AccountService(networkConfig: injected.networkConfig)
        let presenter = YourDetailsPresenter(coordinator: self, accountService: service)
        let vc = YourDetailsViewController(coordinator: self, presenter: presenter)
        navigationRouter.push(viewController: vc, animated: true)
    }
}
