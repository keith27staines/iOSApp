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


struct MockMasterBuilder {
    
    let installationUuid: F4SUUID?
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
            versionCheckCoordinator: self.versionCheckCoordinator)
    }()
    lazy var mockAppInstallationLogic: MockAppInstallationUuidLogic = {
        return MockAppInstallationUuidLogic(registeredInstallationUuid: self.installationUuid)
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
    lazy var mockLocalStore = MockLocalStore()
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
    lazy var user = F4SUser()
    lazy var userRepo: F4SUserRepository = {
        let repo = F4SUserRepository(localStore: self.mockLocalStore)
        repo.save(user: self.user)
        return repo
    }()
    lazy var mockUserService = MockF4SUserService(registeringWillSucceedOnAttempt: 1)
    lazy var mockUserStatusService = MockUserStatusService()
    lazy var versionCheckCoordinator = {
        return VersionCheckCoordinator(
            parent: nil,
            navigationRouter: self.mockNavigationRouter)
    }()
    
    init(userIsRegistered: Bool) {
        self.installationUuid = userIsRegistered ? "installation uuid" : nil
    }
    
    
}

class AppCoordinatorTests: XCTestCase {
    
    var masterBuilder: MockMasterBuilder!
    
    func testCreateAppCoordinator() {
        masterBuilder = MockMasterBuilder(userIsRegistered: true)
        let sut = masterBuilder.appCoordinator
        XCTAssertNotNil(sut.window)
        XCTAssertTrue(sut.window.isKeyWindow)
    }
    
//    func testOnboardingStarted() {
//        masterBuilder = MockMasterBuilder(userIsRegistered: false)
//        let sut = masterBuilder.appCoordinator
//        let expectation = XCTestExpectation(description: "onboardingComplete")
//        let onboardingCoordinator = masterBuilder.mockOnboardingCoordinatorFactory.onboardingCoordinators.last
//        onboardingCoordinator?.testNotifyOnStartCalled = {
//            onboardingCoordinator?.completeOnboarding()
//            XCTAssertEqual(onboardingCoordinator?.startedCount,1)
//            expectation.fulfill()
//        }
//        sut.start()
//        wait(for: [expectation], timeout: 1)
//    }
    
    func makeMasterBuilder(userIsRegistered: Bool) -> MockMasterBuilder {
        return MockMasterBuilder(userIsRegistered: userIsRegistered)
    }
}
