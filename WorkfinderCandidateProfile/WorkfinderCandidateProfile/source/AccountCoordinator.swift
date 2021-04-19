//
//  AccountCoordinator.swift
//  WorkfinderCandidateProfile
//
//  Created by Keith Staines on 08/04/2021.
//

import WorkfinderCommon
import WorkfinderServices
import WorkfinderCoordinators
import WorkfinderRegisterCandidate

public class AccountCoordinator: CoreInjectionNavigationCoordinator {
    var switchToTab: ((TabIndex) -> Void)?
    
    enum ActionRequiringSignin {
        case showDetails
        case showPreferences
    }
    
    var actionRequiringSignin: ActionRequiringSignin?
    
    public init(
        parent: Coordinating?,
        navigationRouter: NavigationRoutingProtocol,
        inject: CoreInjectionProtocol,
        switchToTab: ((TabIndex) -> Void)?
    ) {
        self.switchToTab = switchToTab
        super.init(parent: parent, navigationRouter: navigationRouter, inject: inject)
    }
    
    var accountViewController: AccountViewController?
    
    public override func start() {
        let service = AccountService(networkConfig: injected.networkConfig)
        let presenter = AccountPresenter(coordinator: self, accountService: service)
        let vc = AccountViewController(coordinator: self, presenter: presenter)
        navigationRouter.push(viewController: vc, animated: true)
        accountViewController = vc
    }
    
    func showPreferences() {
        guard UserRepository().isCandidateLoggedIn else {
            actionRequiringSignin = .showPreferences
            showRegisterAndSignin()
            return
        }
        let service = AccountService(networkConfig: injected.networkConfig)
        let presenter = PreferencesPresenter(coordinator: self, accountService: service)
        let vc = PreferencesViewController(coordinator: self, presenter: presenter)
        navigationRouter.push(viewController: vc, animated: true)
    }
    
    func showDetails() {
        guard UserRepository().isCandidateLoggedIn else {
            actionRequiringSignin = .showDetails
            showRegisterAndSignin()
            return
        }
        let service = AccountService(networkConfig: injected.networkConfig)
        let presenter = YourDetailsPresenter(coordinator: self, accountService: service)
        let vc = YourDetailsViewController(coordinator: self, presenter: presenter)
        navigationRouter.push(viewController: vc, animated: true)
    }
    
    func showPicklist(_ picklist: AccountPicklist) {
        let service = AccountService(networkConfig: injected.networkConfig)
        let presenter = PicklistPresenter(coordinator: self, service: service, picklist: picklist)
        let vc = PicklistViewController(coordinator: self, presenter: presenter)
        navigationRouter.push(viewController: vc, animated: true)
    }
    
    func showChangePassword() {
        let service = AccountService(networkConfig: injected.networkConfig)
        let presenter = ChangePasswordPresenter(coordinator: self, accountService: service)
        let vc = ChangePasswordViewController(coordinator: self, presenter: presenter)
        navigationRouter.push(viewController: vc, animated: true)
    }
    
    var registerCoordinator: RegisterAndSignInCoordinator?
    
    func showRegisterAndSignin() {
        let coordinator = RegisterAndSignInCoordinator(parent: self, navigationRouter: navigationRouter, inject: injected, firstScreenHidesBackButton: false)
        addChildCoordinator(coordinator)
        coordinator.startLoginFirst()
    }
    
    func permanentlyRemoveAccount(completion: @escaping (Error?) -> Void) {
        completion(nil)
    }
}

extension AccountCoordinator: RegisterAndSignInCoordinatorParent {
    public func onCandidateIsSignedIn() {
        guard let action = actionRequiringSignin else { return }
        removeRegisterCoordinator()
        switch action {
        case .showDetails: showDetails()
        case .showPreferences: showPreferences()
        }
    }
    
    public func onRegisterAndSignInCancelled() {
        removeRegisterCoordinator()
    }
    
    func removeRegisterCoordinator() {
        guard let accountViewController = accountViewController else { return }
        if let registerCoordinator = registerCoordinator {
            removeChildCoordinator(registerCoordinator)
        }
        navigationRouter.popToViewController(accountViewController, animated: true)
        self.registerCoordinator = nil
    }
}
