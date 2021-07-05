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
import ErrorHandlingUI
import WorkfinderLinkedinSync

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
    
    func showLinkedinData() {
        let service = AccountService(networkConfig: injected.networkConfig)
        let presenter = LinkedinConnectionPresenter(service: service)
        let vc = LinkedinConnectionViewController(presenter: presenter)
        navigationRouter.push(viewController: vc, animated: true)
    }
    
    func doLinkedinSynch() {
        let coordinator = SynchLinkedinCoordinator(parent: self, navigationRouter: navigationRouter, inject: injected)
        addChildCoordinator(coordinator)
        coordinator.syncDidComplete = { syncCoordinator in
            
        }
        coordinator.startIntro()
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
    
    func showPicklist(_ picklist: AccountPicklist, onUpdate: @escaping () -> Void) {
        let service = AccountService(networkConfig: injected.networkConfig)
        let presenter = PicklistPresenter(coordinator: self, service: service, picklist: picklist, onUpdate: onUpdate)
        let vc = PicklistViewController(coordinator: self, presenter: presenter)
        navigationRouter.push(viewController: vc, animated: true)
    }
    
    func showChangePassword() {
        presentContent(.changePassword)
    }
    
    var registerCoordinator: RegisterAndSignInCoordinator?
    
    func showRegisterAndSignin() {
        guard !UserRepository().isCandidateLoggedIn else { return }
        let coordinator = RegisterAndSignInCoordinator(parent: self, navigationRouter: navigationRouter, inject: injected, firstScreenHidesBackButton: false)
        addChildCoordinator(coordinator)
        coordinator.startLoginFirst()
    }
    
    lazy var accountService: AccountServiceProtocol = {
        AccountService(networkConfig: injected.networkConfig)
    }()
    
    func permanentlyRemoveAccountFromServer(email: String, completion: @escaping (Result<DeleteAccountJson,Error>) -> Void) {
        accountService.deleteAccount(email: email) { result in
            if case .success(_) = result {
                LocalStore().resetStore()
            }
            completion(result)
        }
    }
    
    func handleOptionalError(
        optionalError: Error?,
        from vc: WFViewController,
        cancelHandler: @escaping (() -> Void) = {},
        retryHandler: (() -> Void)?) {
        guard let error = optionalError else { return }
        let coord = ErrorHandler(navigationRouter: navigationRouter, coreInjection: injected, parentCoordinator: self)
        addChildCoordinator(coord)
        coord.startHandleError(error, presentingViewController: vc, messageHandler: vc.messageHandler, cancel: cancelHandler, retry: retryHandler ?? {})
    }
}

extension AccountCoordinator: RegisterAndSignInCoordinatorParent {
    public func onCandidateIsSignedIn(preferredNextScreen: PreferredNextScreen) {
        removeRegisterCoordinator()
        guard let action = actionRequiringSignin else { return }
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


