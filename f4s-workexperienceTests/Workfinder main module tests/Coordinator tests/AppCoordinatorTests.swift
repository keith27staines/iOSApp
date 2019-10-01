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

struct MockMasterBuilder: TabbarCoordinatorFactoryProtocol {
    
    let versionIsOkay: Bool
    let installationUuid: F4SUUID?
    let anonymousUserUuid = "anonymous user uuid"
    let apnsEnvironment = "STAGING"
    
    lazy var appCoordinator: AppCoordinator = {
        return AppCoordinator(
            registrar: self.mockApplication,
            navigationRouter: self.mockNavigationRouter,
            inject: self.inject,
            companyCoordinatorFactory: self.mockCompanyCoordinatorFactory,
            companyDocumentsService: self.mockCompanyDocumentsService,
            companyRepository: self.mockCompanyRepository,
            companyService: self.mockCompanyService,
            documentUploaderFactory: self.mockDocumentUploaderFactory,
            emailVerificationModel: self.mockEmailVerificationModel,
            favouritesRepository: self.mockFavouritesRepository,
            localStore: self.mockLocalStore,
            offerProcessingService: self.mockOfferProcessingService,
            onboardingCoordinatorFactory: self.mockOnboardingCoordinatorFactory,
            partnersModel: self.mockPartnersModel,
            placementsRepository: self.mockPlacementsRepository,
            placementService: self.mockPlacementService,
            placementDocumentsServiceFactory: self.mockPlacementDocumentsServiceFactory,
            messageServiceFactory: self.mockMessageServiceFactory,
            messageActionServiceFactory: self.mockMessageActionServiceFactory,
            messageCannedResponsesServiceFactory: self.mockMessageCannedResponsesServiceFactory,
            recommendationsService: self.mockRecommendationsService,
            roleService: self.mockRoleService,
            tabBarCoordinatorFactory: self,
            versionCheckCoordinator: self.mockVersionCheckCoordinator)
    }()
    lazy var mockAppInstallationLogic: MockAppInstallationUuidLogic = {
        let logic = MockAppInstallationUuidLogic(registeredUserUuid: self.anonymousUserUuid)
        logic.registeredInstallationUuid = self.installationUuid
        return logic
    }()
    lazy var mockApplication = MockUIApplication()
    lazy var mockCompanyCoordinatorFactory = MockCompanyCoordinatorFactory()
    lazy var mockCompanyDocumentsService = MockF4SCompanyDocumentService()
    lazy var mockCompanyRepository = MockF4SCompanyRepository()
    lazy var mockCompanyService = MockF4SCompanyService()
    lazy var mockContentService = MockF4SContentService()
    lazy var mockDatabaseDownloadManager = MockDatabaseDownloadManager()
    lazy var mockDocumentUploaderFactory = MockF4SDocumentUploaderFactory()
    lazy var mockEmailVerificationModel = MockF4SEmailVerificationModel()
    lazy var mockFavouritesRepository = MockFavouritingRepository()
    lazy var inject: CoreInjection = {
        return CoreInjection(
            launchOptions: launchOptions,
            appInstallationUuidLogic: self.mockAppInstallationLogic,
            user: self.user,
            userService: self.mockUserService,
            userStatusService: self.mockUserStatusService,
            userRepository: self.userRepo,
            databaseDownloadManager: self.mockDatabaseDownloadManager,
            contentService: self.mockContentService,
            log: self.mockLog)
    }()
    lazy var launchOptions = LaunchOptions()
    lazy var mockLocalStore: LocalStorageProtocol = {
        let store = MockLocalStore()
        if let installationUuid = self.installationUuid {
            store.setValue(installationUuid, for: LocalStore.Key.installationUuid)
        }
        return store
    }()
    lazy var mockLog = MockF4SAnalyticsAndDebugging()
    lazy var mockMessageServiceFactory = MockF4SMessageServiceFactory()
    lazy var mockMessageActionServiceFactory = MockF4SMessageActionServiceFactory()
    lazy var mockMessageCannedResponsesServiceFactory = MockF4SCannedMessageResponsesServiceFactory()
    lazy var navigationController: UINavigationController = {
        return UINavigationController(rootViewController: AppCoordinatorBackgroundViewController())
    }()
    lazy var mockNavigationRouter = MockNavigationRouter()
    lazy var mockOfferProcessingService = MockF4SOfferProcessingService()
    lazy var mockOnboardingCoordinatorFactory = MockOnboardingCoordinatorFactory()
    lazy var mockPartnersModel = MockF4SPartnersModel()
    lazy var mockPlacementsRepository = MockPlacementsRepository()
    lazy var mockPlacementService = MockF4SPlacementService()
    lazy var mockPlacementDocumentsServiceFactory = MockF4SPlacementDocumentsServiceFactory()
    lazy var mockRecommendationsService = MockF4SRecommendationService()
    lazy var mockRoleService = MockF4SRoleService()
    lazy var user: F4SUser = { return F4SUser() }()
    lazy var userRepo: F4SUserRepository = {
        return F4SUserRepository(localStore: self.mockLocalStore)
    }()
    lazy var mockUserService = MockF4SUserService(registeringWillSucceedOnAttempt: 1)
    lazy var mockUserStatusService = MockUserStatusService()
    
    lazy var mockVersionCheckCoordinator: VersionCheckCoordinatorProtocol = {
        let coordinator = MockVersionCheckCoordinator(versionIsOkay: self.versionIsOkay)
        return coordinator
    }()
    
    init(userIsRegistered: Bool, versionIsOkay: Bool) {
        self.installationUuid = "installation uuid" //userIsRegistered ? "installation uuid" : nil
        self.versionIsOkay = versionIsOkay
        var user: F4SUser = F4SUser()
        if userIsRegistered {
            user.uuid = "anonymous user uuid"
        }
        self.userRepo.save(user: user)
    }
    
    func makeTabBarCoordinator(parent: Coordinating,
                               router: NavigationRoutingProtocol,
                               inject: CoreInjectionProtocol) -> TabBarCoordinatorProtocol {
        return MockTabBarCoordinator(
            parent: parent,
            navigationRouter: router,
            inject: inject)
    }
    
}

class AppCoordinatorTests: XCTestCase {
    
    var masterBuilder: MockMasterBuilder!
    
    func testCreateAppCoordinator() {
        masterBuilder = MockMasterBuilder(userIsRegistered: true, versionIsOkay: false )
        let sut = masterBuilder.appCoordinator
        XCTAssertNotNil(sut.window)
        XCTAssertTrue(sut.window.isKeyWindow)
    }
    
    func test_versionCheck_called_and_onboarding_not_called_when_version_invalid() {
        masterBuilder = MockMasterBuilder(userIsRegistered: false, versionIsOkay: false)
        let sut = masterBuilder.appCoordinator
        let expectation = XCTestExpectation(description: "")
        let versionCheckCoordinator = masterBuilder.mockVersionCheckCoordinator as! MockVersionCheckCoordinator
        var masterBuilder = self.masterBuilder!
        versionCheckCoordinator.testVersionCheckWasCalled = {
            let onboardingCoordinator = masterBuilder.mockOnboardingCoordinatorFactory.onboardingCoordinators.last
            XCTAssertNil(onboardingCoordinator)
            expectation.fulfill()
        }
        sut.start()
        wait(for: [expectation], timeout: 1)
    }
    
    func test_versionCheck_called_and_onboarding_started_when_version_valid() {
        masterBuilder = MockMasterBuilder(userIsRegistered: false, versionIsOkay: true)
        let sut = masterBuilder.appCoordinator
        let expectation = XCTestExpectation(description: "")
        let versionCheckCoordinator = masterBuilder.mockVersionCheckCoordinator as! MockVersionCheckCoordinator
        var masterBuilder = self.masterBuilder!
        versionCheckCoordinator.testVersionCheckWasCalled = {
            let onboardingCoordinator = masterBuilder.mockOnboardingCoordinatorFactory.onboardingCoordinators.last
            XCTAssertTrue(onboardingCoordinator?.startedCount == 1)
            expectation.fulfill()
        }
        sut.start()
        wait(for: [expectation], timeout: 1)
    }
    
    func test_ensureDeviceIsRegistered_is_called() {
        masterBuilder = MockMasterBuilder(userIsRegistered: false, versionIsOkay: true)
        let sut = masterBuilder.appCoordinator
        let expectation = XCTestExpectation(description: "")
        var masterBuilder = self.masterBuilder!
        let appInstallationLogic = masterBuilder.mockAppInstallationLogic
        appInstallationLogic.testDidComplete = {
            expectation.fulfill()
        }
        sut.start()
        wait(for: [expectation], timeout: 1000)
    }
    
    func test_tabBar_created_when_onboardingFinishes() {
        masterBuilder = MockMasterBuilder(userIsRegistered: true, versionIsOkay: true)
        let sut = masterBuilder.appCoordinator
        let expectation = XCTestExpectation(description: "")
        let versionCheckCoordinator = masterBuilder.mockVersionCheckCoordinator as! MockVersionCheckCoordinator
        var masterBuilder = self.masterBuilder!
        versionCheckCoordinator.testVersionCheckWasCalled = {
            let onboardingCoordinator = masterBuilder.mockOnboardingCoordinatorFactory.onboardingCoordinators.last
            onboardingCoordinator?.completeOnboarding()
            XCTAssertNotNil(sut.tabBarCoordinator)
            expectation.fulfill()
        }
        sut.start()
        wait(for: [expectation], timeout: 1)
    }

}
