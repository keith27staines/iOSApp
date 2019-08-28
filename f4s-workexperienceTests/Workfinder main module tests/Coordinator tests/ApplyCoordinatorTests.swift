//
//  ApplyCoordinatorTests.swift
//  f4s-workexperienceTests
//
//  Created by Keith Dev on 14/03/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import XCTest
import WorkfinderCommon
import WorkfinderNetworking
import WorkfinderServices
import WorkfinderAppLogic
import WorkfinderApplyUseCase

@testable import f4s_workexperience

class ApplyCoordinatorTests: XCTestCase {
    
    let mockRouter = MockNavigationRouter()
    let mockRegisteredUser = MockF4SUser.makeRegisteredUser()
    let mockUnregisteredUser = MockF4SUser.makeRegisteredUser()
    let mockUserService = MockUserService(registeringWillSucceedOnAttempt: 1)
    let mockUserStatusService = MockUserStatusService()
    let mockDatabaseDownloadManager = MockDatabaseDownloadManager()
    let mockAnalytics = MockF4SAnalyticsAndDebugging()
    var mockPlacementServiceFactory = MockPlacementServiceFactory(errorResponseCode: 404)
    
    func makeMockAppInstallationLogic(
        installationUuid: String?,
        user: F4SUserProtocol,
        isRegistered: Bool) -> AppInstallationUuidLogic {
        let localStore = MockLocalStore()
        let userRepo = MockUserRepository(user: user)
        localStore.setValue("installationUuid", for: LocalStore.Key.installationUuid)
        localStore.setValue(isRegistered, for: LocalStore.Key.isDeviceRegistered)
        let logic = AppInstallationUuidLogic(localStore: localStore, userService: mockUserService, userRepo: userRepo)
        return logic
    }
    
    lazy var mockedInjection: CoreInjection = {
        let injection = CoreInjection(
            launchOptions: nil,
            appInstallationUuidLogic: makeMockAppInstallationLogic(installationUuid: "installationUuid", user: mockRegisteredUser, isRegistered: true),
            user: mockRegisteredUser,
            userService: mockUserService,
            userRepository: MockUserRepository(user: mockRegisteredUser),
            databaseDownloadManager: mockDatabaseDownloadManager,
            f4sLog: mockAnalytics
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
        let placementServiceFactory = MockPlacementServiceFactory(errorResponseCode: 404)
        let mockPlacementService = placementServiceFactory.makePlacementService()
        let mockTemplateService = MockTemplateService()
        let sut = ApplyCoordinator(
            company: company,
            placement: nil,
            parent: nil,
            navigationRouter: mockRouter,
            inject: mockedInjection,
            placementService: mockPlacementService,
            templateService: mockTemplateService)
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

class MockPlacementServiceFactory : F4SPlacementApplicationServiceFactoryProtocol {
    var successJson: F4SPlacementJson?
    let responseStatusCode: HTTPStatusCode
    
    init(successCreatePlacementJson: F4SPlacementJson) {
        self.successJson = successCreatePlacementJson
        self.responseStatusCode = 200
    }
    
    init(errorResponseCode: HTTPStatusCode) {
        self.responseStatusCode = errorResponseCode
    }
    
    func makePlacementService() -> F4SPlacementApplicationServiceProtocol {
        let url = URL(string: "somewhere.com")!
        let httpResponse = HTTPURLResponse(url: url, statusCode: responseStatusCode, httpVersion: "1.0", headerFields: nil)!
        
        if let networkError = F4SNetworkError(response: httpResponse, attempting: "test") {
            let result = F4SNetworkResult<F4SPlacementJson>.error(networkError)
            return MockF4SPlacementApplicationService(createResult: result)
        } else {
            let result = F4SNetworkResult.success(successJson!)
            return MockF4SPlacementApplicationService(createResult: result)
        }
    }
}

class MockTemplateService : F4STemplateServiceProtocol {
    func getTemplates(completion: @escaping (F4SNetworkResult<[F4STemplate]>) -> Void) {
        
    }
}

class MockPlacementService : F4SPlacementApplicationServiceProtocol {
    func apply(with json: F4SCreatePlacementJson, completion: @escaping (F4SNetworkResult<F4SPlacementJson>) -> Void) {
        
    }
    
    func update(uuid: F4SUUID, with json: F4SPlacementJson, completion: @escaping (F4SNetworkResult<F4SPlacementJson>) -> Void) {
        
    }
}
