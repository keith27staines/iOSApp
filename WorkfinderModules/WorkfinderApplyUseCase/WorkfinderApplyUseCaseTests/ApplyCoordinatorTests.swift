//
//  ApplyCoordinatorTests.swift
//  f4s-workexperienceTests
//
//  Created by Keith Dev on 14/03/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import XCTest
import WorkfinderCommon
import WorkfinderCoordinators

@testable import WorkfinderApplyUseCase

class ApplyCoordinatorTests: XCTestCase {
    
    let mockRouter = MockNavigationRouter()
    let mockRegisteredUser = F4SUser(uuid: "userUuid1234")
    let mockUnregisteredUser = F4SUser()
    let mockUserService = MockF4SUserService(registeringWillSucceedOnAttempt: 1)
    let mockUserStatusService = MockF4SUserStatusService()
    let mockDatabaseDownloadManager = MockDatabaseDownloadManager()
    let mockAnalytics = MockF4SAnalyticsAndDebugging()
    let mockAppSettings = MockAppSettingProvider()
    var mockPlacementServiceFactory = MockF4SPlacementServiceFactory(errorResponseCode: 404)
    
    lazy var mockedInjection: CoreInjection = {
        let userStatusService = MockF4SUserStatusService()
        let mockContentService = MockF4SContentService()
        let injection = CoreInjection(
            launchOptions: nil,
            appInstallationUuidLogic: MockAppInstallationUuidLogic(registeredUserUuid: "registerdeUuid"),
            user: mockRegisteredUser,
            userService: mockUserService,
            userStatusService: userStatusService,
            userRepository: MockUserRepository(user: mockRegisteredUser),
            databaseDownloadManager: mockDatabaseDownloadManager,
            contentService: mockContentService,
            log: mockAnalytics,
            appSettings: mockAppSettings
        )
        return injection
    }()

    func testStart_withoutPlacement() {
        let sut = makeSUTApplyCoordinator(company: "company1234", continueExistingApplication: nil)
        sut.start()
        XCTAssertEqual(mockRouter.pushedViewControllers.count,1)
        XCTAssertTrue(mockRouter.pushedViewControllers.first! is ApplicationLetterViewController)
    }
    
    func testStart_withPlacement() {
        let sut = makeSUTApplyCoordinator(company: "company1234", continueExistingApplication: "placementUuid")
        sut.start()
        XCTAssertEqual(mockRouter.pushedViewControllers.count,1)
        XCTAssertTrue(mockRouter.pushedViewControllers.first! is ApplicationLetterViewController)
    }

}

extension ApplyCoordinatorTests {
    
    func makeSUTApplyCoordinator(company: F4SUUID, continueExistingApplication uuid: F4SUUID? = nil) -> ApplyCoordinator {
        let now = Date()
        let company = Company(id: 1, created: now, modified: now, isAvailableForSearch: true, uuid: "companyUuid", name: "Test Company", logoUrl: "logoUrl", industry: "Test Industry", latitude: 51, longitude: 0, summary: "This is a test company", employeeCount: 7, turnover: 3, turnoverGrowth: 3, rating: 0, ratingCount: 0, sourceId: "some unknown source", hashtag: "", companyUrl: "companyUrl")
        let placementServiceFactory = MockF4SPlacementServiceFactory(errorResponseCode: 404)
        let mockPlacementService = placementServiceFactory.makePlacementService()
        let mockTemplateService = MockF4STemplateService()
        let mockPlacementRepository = MockPlacementsRepository()
        let mockInterestsRepository = MockF4SInterestsRepository()
        let placement = F4STimelinePlacement(userUuid: "userUuid", companyUuid: "companyUuid", placementUuid: "placementUuid")
        let requiredPlacementResult = F4SNetworkResult.success([placement])
        let mockGetAllPlacementsService = MockF4SGetAllPlacementsService(result: requiredPlacementResult)
        let mockEmailVerificationModel = MockF4SEmailVerificationModel()
        let mockPlacementDocumentsServiceFactory = MockF4SPlacementDocumentsServiceFactory()
        let mockUploaderFactory = MockF4SDocumentUploaderFactory()
        let sut = ApplyCoordinator(
            company: company,
            parent: nil,
            navigationRouter: mockRouter,
            inject: mockedInjection,
            environment: EnvironmentType.staging,
            placementService: mockPlacementService,
            templateService: mockTemplateService,
            placementRepository: mockPlacementRepository,
            interestsRepository: mockInterestsRepository,
            getAllPlacementsService: mockGetAllPlacementsService,
            emailVerificationModel: mockEmailVerificationModel,
            documentServiceFactory: mockPlacementDocumentsServiceFactory,
            documentUploaderFactory: mockUploaderFactory)
        return sut
    }
    
    func makePlacementJsonForCompany(
        company: CompanyViewData,
        userUuid: F4SUUID = "user1",
        placementUuid: F4SUUID = "placement1",
        workflowState: F4SPlacementState = .draft,
        interests: [F4SUUID] = []) -> F4SPlacementJson {
        var placement = F4SPlacementJson(uuid: "1", user: userUuid, company: company.uuid, vendor: "vendorId", interests: interests)
        placement.companyUuid = company.uuid
        placement.userUuid = userUuid
        placement.uuid = placementUuid
        placement.workflowState = workflowState
        placement.interests = interests
        return placement
    }
    
    func makeCompanyViewData() -> CompanyViewData {
        let companyViewData = CompanyViewData()
        return companyViewData
    }
    
}

