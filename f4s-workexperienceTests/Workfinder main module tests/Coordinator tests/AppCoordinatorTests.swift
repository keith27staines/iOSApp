//
//  AppCoordinatorTests.swift
//  f4s-workexperienceTests
//
//  Created by Keith Dev on 15/02/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import XCTest

@testable import f4s_workexperience

class AppCoordinatorTests: XCTestCase {
    
    var mockRegistrar = MockUIApplication()
    var injection: CoreInjection!
    var mockRouter = MockNavigationRouter()
    var mockUserService = MockUserService(registeringWillSucceedOnAttempt: 1)
    var mockRegisteredUser = MockF4SUser.makeRegisteredUser()
    var mockUnregisteredUser = MockF4SUser.makeUnregisteredUser()
    var mockAnalytics = MockF4SAnalyticsAndDebugging()
    var mockDatabaseDownloadManager = MockDatabaseDownloadManager()
    var sut: AppCoordinator!
    var mockOnboardingCoordinator: MockOnboardingCoordinator!
    
    override func setUp() {
        super.setUp()
        injection = CoreInjection(
            launchOptions: nil,
            installationUuid: "installationUuid",
            user: mockUnregisteredUser,
            userService: mockUserService,
            databaseDownloadManager: mockDatabaseDownloadManager,
            f4sLog: mockAnalytics
        )
        sut = makeSUTAppCoordinator(router: mockRouter, injecting: injection)
        mockOnboardingCoordinator = MockOnboardingCoordinator(parent: sut)
    }
    
    override func tearDown() {}
    
    func testCreateAppCoordinator() {
        XCTAssertNotNil(sut.window)
        XCTAssertTrue(sut.window.isKeyWindow)
    }
    
    func testDefaultUserService() {
        sut = AppCoordinatoryFactory().makeAppCoordinator(registrar: mockRegistrar, installationUuid: "installationUuid", f4sLog: mockAnalytics) as? AppCoordinator
        XCTAssertNotNil(sut.userService)
    }
    
    func testStartWithUnregisteredAndNotOnboardedUser() {
        mockUnregisteredUser.isOnboarded = false
        injection.user = mockUnregisteredUser
        let sut = makeSUTAppCoordinator(router: mockRouter, injecting: injection)
        sut.start()
        mockOnboardingCoordinator.completeOnboarding()
        assertOnboardingCompleteCompleteState(sut: sut, expectedRegisterUserCount: 1)
    }
    
    func testStartWithRegisteredButNotOnboardedUser() {
        mockRegisteredUser.isOnboarded = false
        injection.user = mockRegisteredUser
        let sut = makeSUTAppCoordinator(router: mockRouter, injecting: injection)
        sut.start()
        mockOnboardingCoordinator.completeOnboarding()
        assertOnboardingCompleteCompleteState(sut: sut, expectedRegisterUserCount: 1)
    }
    
    func testStartWithRegisteredAndOnboardedUser() {
        mockRegisteredUser.isOnboarded = true
        injection.user = mockRegisteredUser
        let sut = makeSUTAppCoordinator(router: mockRouter, injecting: injection)
        sut.start()
        assertOnboardingCompleteCompleteState(sut: sut, expectedRegisterUserCount: 1)
    }
}

// MARK:- AppCoordinatorTests helpers
extension AppCoordinatorTests {
    
    func makeSUTAppCoordinator(router: NavigationRoutingProtocol, injecting: CoreInjectionProtocol) -> AppCoordinator {
        let navigationRouter = MockNavigationRouter()
        let appCoordinator = AppCoordinator(
            registrar: MockUIApplication(),
            navigationRouter: navigationRouter,
            inject: injecting)
        
        appCoordinator.onboardingCoordinatorFactory = {[weak self] _,_ in
            return self!.mockOnboardingCoordinator
        }
        
        appCoordinator.tabBarCoordinatorFactory = { parent, router, injection in
            return MockTabBarCoordinator(
                parent: parent,
                navigationRouter: router,
                inject: injection)
        }
        return appCoordinator
    }
    
    func assertOnboardingCompleteCompleteState(
        sut: AppCoordinator,
        expectedRegisterUserCount: Int) {
        
        XCTAssertNotNil(sut.user.uuid)
        XCTAssertEqual(mockRouter.presentedViewControllers.count, 0)
        XCTAssertEqual(mockOnboardingCoordinator.startedCount, 1)
        XCTAssertEqual(sut.childCoordinators.count, 1)
        XCTAssertTrue(sut.childCoordinators.first?.value is MockCoreInjectionNavigationCoordinator )
        XCTAssertEqual(mockUserService.registerAnonymousUserOnServerCalled, expectedRegisterUserCount)
    }
}

