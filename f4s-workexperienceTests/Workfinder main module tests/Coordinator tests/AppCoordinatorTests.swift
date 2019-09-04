//
//  AppCoordinatorTests.swift
//  f4s-workexperienceTests
//
//  Created by Keith Dev on 15/02/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import XCTest
import WorkfinderCommon
import WorkfinderServices
import WorkfinderAppLogic
import WorkfinderCoordinators

@testable import f4s_workexperience

class AppCoordinatorTests: XCTestCase {
    
    var mockRegistrar = MockUIApplication()
    var injection: CoreInjection!
    var mockRouter = MockNavigationRouter()
    var mockUserService = MockUserService(registeringWillSucceedOnAttempt: 1)
    var mockUserStatusService = MockUserStatusService()
    var mockRegisteredUser = makeRegisteredUser()
    var mockUnregisteredUser = makeUnregisteredUser()
    var mockAnalytics = MockF4SAnalyticsAndDebugging()
    var mockDatabaseDownloadManager = MockDatabaseDownloadManager()
    var sut: AppCoordinator!
    var mockOnboardingCoordinator: MockOnboardingCoordinator!
    var versionCheckCoordinator: VersionCheckCoordinator!
    
    override func setUp() {
        super.setUp()
        let user = mockUnregisteredUser
        let localStore = MockLocalStore()
        let logic = AppInstallationUuidLogic(localStore: localStore, userService: mockUserService, userRepo: MockUserRepository(user: user))
        injection = CoreInjection(
            launchOptions: nil,
            appInstallationUuidLogic: logic,
            user: user,
            userService: mockUserService,
            userStatusService: mockUserStatusService,
            userRepository: MockUserRepository(user: mockUnregisteredUser),
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
        sut = makeSUTAppCoordinator(router: mockRouter, injecting: injection)
        XCTAssertNotNil(sut.userService)
    }
    
    func testOnboardingStarted() {
        injection.user = mockUnregisteredUser
        let onboardingComplete = XCTestExpectation(description: "onboardingComplete")
        let sut = makeSUTAppCoordinator(router: mockRouter, injecting: injection)
        mockOnboardingCoordinator.testNotifyOnStartCalled = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.mockOnboardingCoordinator.completeOnboarding()
            strongSelf.assertOnboardingCompleteCompleteState(sut: sut)
            onboardingComplete.fulfill()
        }
        sut.start()
        wait(for: [onboardingComplete], timeout: 1)
    }
}

func makeRegisteredUser() -> F4SUser {
    return F4SUser(uuid: "uuid")
}

func makeUnregisteredUser() -> F4SUser {
    return F4SUser()
}

// MARK:- AppCoordinatorTests helpers
extension AppCoordinatorTests {
    
    func makeSUTAppCoordinator(router: NavigationRoutingProtocol, injecting: CoreInjectionProtocol) -> AppCoordinator {
        versionCheckCoordinator = VersionCheckCoordinator(parent: nil, navigationRouter: router)
        versionCheckCoordinator.versionCheckService = MockVersionCheckingService(versionIsGood: true)
        let appCoordinator = AppCoordinator(
            versionCheckCoordinator: versionCheckCoordinator,
            registrar: MockUIApplication(),
            navigationRouter: router,
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
    
    func assertOnboardingCompleteCompleteState(sut: AppCoordinator) {
        XCTAssertEqual(mockRouter.presentedViewControllers.count, 0)
        XCTAssertEqual(mockOnboardingCoordinator.startedCount, 1)
    }
}

class MockVersionCheckingService: F4SWorkfinderVersioningServiceProtocol {
    
    var versionIsGood: Bool
    
    init(versionIsGood: Bool) {
        self.versionIsGood = versionIsGood
    }
    
    func getIsVersionValid(completion: @escaping (F4SNetworkResult<F4SVersionValidity>) -> ()) {
        let result = F4SNetworkResult.success(versionIsGood)
            completion(result)
    }
}

class MockUserRepository: F4SUserRepositoryProtocol {
    var user: F4SUser
    init(user: F4SUser) {
        self.user = user
    }
    
    func save(user: F4SUser) {
        self.user = user
    }
    
    func load() -> F4SUser {
        return user
    }
}

