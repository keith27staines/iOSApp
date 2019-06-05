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
import WorkfinderApplyUseCase

@testable import f4s_workexperience

class ApplyCoordinatorTests: XCTestCase {
    
    let mockRouter = MockNavigationRouter()
    let mockRegisteredUser = MockF4SUser.makeRegisteredUser()
    let mockUnregisteredUser = MockF4SUser.makeRegisteredUser()
    let mockUserService = MockUserService(registeringWillSucceedOnAttempt: 1)
    let mockDatabaseDownloadManager = MockDatabaseDownloadManager()
    let mockAnalytics = MockF4SAnalyticsAndDebugging()
    var mockPlacementServiceFactory = MockPlacementServiceFactory(errorResponseCode: 404)
    
    lazy var mockedInjection = CoreInjection(
        launchOptions: nil,
        installationUuid: "installationUuid",
        user: mockRegisteredUser,
        userService: mockUserService,
        userRepository: MockUserRepository(user: mockRegisteredUser),
        databaseDownloadManager: mockDatabaseDownloadManager,
        f4sLog: mockAnalytics)

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
        workflowState: WEXPlacementState = .draft,
        interests: [F4SUUID] = []) -> WEXPlacementJson {
        var placement = WEXPlacementJson(uuid: "1", user: userUuid, company: company.uuid, vendor: "vendorId", interests: interests)
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

class MockPlacementServiceFactory : WEXPlacementServiceFactoryProtocol {
    var successJson: WEXPlacementJson?
    let responseStatusCode: HTTPStatusCode
    
    init(successCreatePlacementJson: WEXPlacementJson) {
        self.successJson = successCreatePlacementJson
        self.responseStatusCode = 200
    }
    
    init(errorResponseCode: HTTPStatusCode) {
        self.responseStatusCode = errorResponseCode
    }
    
    func makePlacementService() -> WEXPlacementServiceProtocol {
        let url = URL(string: "somewhere.com")!
        let httpResponse = HTTPURLResponse(url: url, statusCode: responseStatusCode, httpVersion: "1.0", headerFields: nil)!
        if let error = WEXErrorsFactory.networkErrorFrom(response: httpResponse, responseData: nil, attempting: "test") {
            let result = WEXResult<WEXPlacementJson,WEXError>.failure(error)
            return MockWEXPlacementService(result: result)
        } else {
            let result = WEXResult<WEXPlacementJson,WEXError>.success(successJson!)
            return MockWEXPlacementService(result: result)
        }
    }
}

class MockTemplateService : F4STemplateServiceProtocol {
    func getTemplates(completion: @escaping (F4SNetworkResult<[F4STemplate]>) -> Void) {
        
    }
}

class MockPlacementService : WEXPlacementServiceProtocol {
    func createPlacement(with json: WEXCreatePlacementJson, completion: @escaping (WEXResult<WEXPlacementJson, WEXError>) -> Void) {
    
    }
    
    func patchPlacement(uuid: F4SUUID, with json: WEXPlacementJson, completion: @escaping (WEXResult<WEXPlacementJson, WEXError>) -> Void) {
        
    }
    
    
}
