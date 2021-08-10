//
//  NameCaptureCoordinator.swift
//  WorkfinderCandidateProfile
//
//  Created by Keith on 21/07/2021.
//

import Foundation
import WorkfinderCommon
import WorkfinderServices
import WorkfinderCoordinators

public class NameCaptureCoordinator: CoreInjectionNavigationCoordinator {
    
    var onComplete: (() -> Void)?
    var service: UpdateUserService
    
    
    var user: User {
        get { injected.userRepository.loadUser() }
        set { injected.userRepository.saveUser(newValue) }
    }
    
    public static var isNameCaptureRequired: Bool {
        let user = UserRepository().loadUser()
        let first = user.firstname
        let last = user.lastname
        let testString = (first ?? "") + (last ?? "")
        return testString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    public init(
        parent: Coordinating?,
        navigationRouter: NavigationRoutingProtocol,
        inject: CoreInjectionProtocol,
        onComplete: @escaping () -> Void
    ) {
        self.service = UpdateUserService(networkConfig: inject.networkConfig)
        self.onComplete = onComplete
        super.init(parent: parent, navigationRouter: navigationRouter, inject: inject)
    }
    
    public override func start() {
        guard NameCaptureCoordinator.isNameCaptureRequired else {
            parentCoordinator?.childCoordinatorDidFinish(self)
            self.onComplete?()
            return
        }
        let service = UpdateUserService(networkConfig: injected.networkConfig)
        let vc = NameCaptureViewController(hideBackButton: true, updateUserService: service, userRepository: injected.userRepository, onComplete: onComplete ?? {})
        navigationRouter.push(viewController: vc, animated: true)
    }
    
    public func onDidCancel() {
        navigationRouter.pop(animated: true)
        parentCoordinator?.childCoordinatorDidFinish(self)
    }
    
    public func onNamesCaptured() {
        self.onComplete?()
    }
}

