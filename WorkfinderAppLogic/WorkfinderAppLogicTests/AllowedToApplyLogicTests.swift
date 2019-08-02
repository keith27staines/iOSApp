//
//  AllowedToApplyLogicTests.swift
//  WorkfinderAppLogicTests
//
//  Created by Keith Dev on 01/08/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import XCTest
import WorkfinderCommon
import WorkfinderNetworking
import WorkfinderServices
@testable import WorkfinderAppLogic

class AllowedToApplyLogicTests: XCTestCase {

    func test_initialise_with_injected_placement_service() {
        let result = F4SNetworkResult.success([F4STimelinePlacement]())
        let service = MockF4SGetAllPlacementsService(result: result)
        let sut = AllowedToApplyLogic(service: service)
        XCTAssertTrue((sut.placementService as? MockF4SGetAllPlacementsService) === service)
    }
    
    func test_allowed_if_existing_placements_excludes_company() {
        let userUuid = "user"
        let companyUuid = "company"
        let sut = makeSUT()
        let existing = [F4STimelinePlacement(userUuid: userUuid,
                                             companyUuid: companyUuid,
                                             placementUuid: "placement")]
        let expectation = XCTestExpectation()
        sut.checkUserCanApply(user: userUuid, to: "other_company", givenExistingPlacements: existing) { result in
            switch result {
            case .success(true):
                expectation.fulfill()
            default:
                XCTFail("There is no existing placement to the company so the result should be `true`")
            }
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func test_allowed_if_existing_placements_includes_company() {
        let userUuid = "user"
        let companyUuid = "company-already-applied"
        let sut = makeSUT()
        let existing = [F4STimelinePlacement(userUuid: userUuid,
                                             companyUuid: companyUuid,
                                             placementUuid: "placement")]
        let expectation = XCTestExpectation()
        sut.checkUserCanApply(user: userUuid, to: "company-already-applied", givenExistingPlacements: existing) { result in
            switch result {
            case .success(false):
                expectation.fulfill()
            default:
                XCTFail("There is an existing placement to the company so the result should be `false`")
            }
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func test_allowed_if_existing_placements_not_injected_and_placementService_returns_empty() {
        let userUuid = "user"
        let companyUuid = "company"
        let sut = makeSUT()
        let expectation = XCTestExpectation()
        sut.checkUserCanApply(user: userUuid, to: companyUuid) { result in
            switch result {
            case .success(true):
                expectation.fulfill()
            default:
                XCTFail("No placement exists for the company so result should be `true`")
            }
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func test_allowed_if_existing_placements_not_injected_and_placementService_returns_match() {
        let userUuid = "user"
        let companyUuid = "existing-company"
        let existingPlacement = F4STimelinePlacement(userUuid: userUuid, companyUuid: companyUuid, placementUuid: "placement")
        let result = F4SNetworkResult.success([existingPlacement])
        let service = MockF4SGetAllPlacementsService(result: result)
        let sut = AllowedToApplyLogic(service: service)
        let expectation = XCTestExpectation()
        sut.checkUserCanApply(user: userUuid, to: companyUuid) { result in
            switch result {
            case .success(false):
                expectation.fulfill()
            default:
                XCTFail("A placement exists for the company so result should be `false`")
            }
        }
        wait(for: [expectation], timeout: 1)
    }
}

extension AllowedToApplyLogicTests {
    func makeSUT() -> AllowedToApplyLogic {
        let result = F4SNetworkResult.success([F4STimelinePlacement]())
        let service = MockF4SGetAllPlacementsService(result: result)
        let sut = AllowedToApplyLogic(service: service)
        return sut
    }
}

class MockF4SGetAllPlacementsService: F4SGetAllPlacementsServiceProtocol {
    
    var result: F4SNetworkResult<[F4STimelinePlacement]>
    
    init(result: F4SNetworkResult<[F4STimelinePlacement]>) {
        self.result = result
    }
    
    func getAllPlacementsForUser(completion: @escaping (F4SNetworkResult<[F4STimelinePlacement]>) -> ()) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            completion(strongSelf.result)
        }
    }
}
