//
//  MockOnboarding.swift
//  f4s-workexperienceTests
//
//  Created by Keith Dev on 20/02/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation
import WorkfinderCommon
import WorkfinderOnboardingUseCase

@testable import f4s_workexperience

class MockTabBarCoordinator : MockCoreInjectionNavigationCoordinator, TabBarCoordinatorProtocol {
    
    var showSearchCallCount: Int = 0
    var showMessagesCallCount: Int = 0
    var updateUnreadMessagesCallCount: Int = 0
    
    func showSearch() {
        showSearchCallCount += 1
    }
    
    func showMessages() {
        showMessagesCallCount += 1
    }
    
    func updateUnreadMessagesCount(_ count: Int) {
        updateUnreadMessagesCallCount += 1
    }
    
    var menuOpen: Bool = false
    func toggleMenu(completion: ((Bool) -> ())?) {
        menuOpen.toggle()
        completion?(menuOpen)
    }
    
    var shouldAskOperatingSystemToAllowLocation: Bool = false
    required init(parent: Coordinating?, navigationRouter: NavigationRoutingProtocol, inject: CoreInjectionProtocol) {
        super.init(parent: parent, navigationRouter: navigationRouter, inject: inject)
    }
}

class MockParentCoordinator: Coordinating {
    
    var parentCoordinator: Coordinating? = nil
    var uuid: UUID = UUID()
    var childCoordinators = [UUID : Coordinating]()
    var router: NavigationRoutingProtocol
    init(router: NavigationRoutingProtocol) {
        self.router = router
    }
    
    func start() {}
    
}

class MockCoreInjectionNavigationCoordinator : CoreInjectionNavigationCoordinatorProtocol {
    
    var parentCoordinator: Coordinating?
    var uuid: UUID = UUID()
    var childCoordinators = [UUID : Coordinating]()
    var injected: CoreInjectionProtocol
    var navigationRouter: NavigationRoutingProtocol
    
    var startedCount: Int = 0
    func start() { startedCount += 1 }
    
    required init(parent: Coordinating?, navigationRouter: NavigationRoutingProtocol, inject: CoreInjectionProtocol) {
        self.parentCoordinator = parent
        self.navigationRouter = navigationRouter
        self.injected = inject
    }
}

class MockOnboardingCoordinator : OnboardingCoordinatorProtocol {
    
    var hideOnboardingControls: Bool = true
    
    var delegate: OnboardingCoordinatorDelegate?
    
    var onboardingDidFinish: ((OnboardingCoordinatorProtocol) -> Void)?
    
    var parentCoordinator: Coordinating?
    var uuid: UUID = UUID()
    var childCoordinators = [UUID : Coordinating]()
    
    var testNotifyOnStartCalled: (() -> Void)?
    
    init(parent: Coordinating?) {
        parentCoordinator = parent
    }
    
    var startedCount: Int = 0 {
        didSet {
            print("Started count \(startedCount)")
        }
    }
    func start() {
        startedCount += 1
        testNotifyOnStartCalled?()
    }
    
    /// Call this method to simulate the affect of the onboarding coordinator finishing its last user interaction
    func completeOnboarding() {
        onboardingDidFinish?(self)
    }
}
