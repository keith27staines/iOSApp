//
//  F4SPlacementServiceTests.swift
//  WorkfinderServicesTests
//
//  Created by Keith Dev on 19/08/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import XCTest
import WorkfinderCommon
import WorkfinderNetworking
@testable import WorkfinderServices

class F4SPlacementServiceTests: XCTestCase {
    let sessionManager = MockF4SNetworkSessionManager()
    let previousTask = MockNetworkTask<String>(verb: F4SHttpRequestVerb.get, attempting: "something previous", session: MockF4SNetworkSessionManager().interactiveSession) { (result) in
    }
    
    func test_getPlacement_with_success_result() {
        let timelinePlacement = F4STimelinePlacement(userUuid: "userUuid", companyUuid: "companyUuid", placementUuid: "placementUuid")
        let successResult = F4SNetworkResult.success(timelinePlacement)
        let sut = makeSUT(successResult: successResult)
        let expectation = XCTestExpectation(description: "")
        sut.getPlacementOffer(uuid: "placementUuid") { (result) in
            switch result {
            case .error(_):
                XCTFail("The test was intended to return a success result")
            case .success(let placement):
                XCTAssertEqual(placement.placementUuid, "placementUuid")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(sut.sessionManager as! MockF4SNetworkSessionManager === sessionManager)
        XCTAssertTrue(previousTask.cancelWasCalled)
        assertMockDataTask(sut.dataTask as!MockNetworkTask<F4STimelinePlacement>, verb: .get, url: "/v2/placement/placementUuid")
    }
    
    func test_getPlacement_with_error_result() {
        let sut = F4SPlacementService(sessionManager: sessionManager)
        sut.networkTaskFactory = MockF4SNetworkTaskFactory<F4STimelinePlacement>(userUuid: "uuid", requiredNetworkError: F4SNetworkError(error: "test error", attempting: "get placement"))
        let expectation = XCTestExpectation(description: "")
        sut.getPlacementOffer(uuid: "placementuuid") { (result) in
            switch result {
            case .error(_):
                break
            case .success(_):
                XCTFail("The test was intended to return an error result")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func test_patchPlacement() {
        let patchJson: [String: String] = ["key":"value"]
        let resultJson: [String: String?] = ["true": nil]
        let successResult = F4SNetworkResult.success(resultJson)
        let sut = makeSUT(successResult: successResult)
        let expectation = XCTestExpectation(description: "")
        sut.patchPlacement("placementUuid", json: patchJson, attempting: "patch", completion: { (result) in
            switch result {
            case .error(_):
                XCTFail("The test was intended to return a success result")
            case .success(let booleanValue):
                XCTAssertTrue(booleanValue)
            }
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(sut.sessionManager as! MockF4SNetworkSessionManager === sessionManager)
        XCTAssertTrue(previousTask.cancelWasCalled)
        assertMockDataTask(sut.dataTask as! MockNetworkTask<[String: String?]>, verb: .patch, url: "/v2/placement/placementUuid")
    }
    
    func test_confirm() {
        let resultJson: [String: String?] = ["true": nil]
        let successResult = F4SNetworkResult.success(resultJson)
        let sut = makeSUT(successResult: successResult)
        let expectation = XCTestExpectation(description: "")
        let placement = F4STimelinePlacement(userUuid: "userUuid", companyUuid: "companyUuid", placementUuid: "placementUuid")
        sut.confirmPlacement(placement: placement) { (result) in
            switch result {
            case .error(_):
                XCTFail("The test was intended to return a success result")
            case .success(let booleanValue):
                XCTAssertTrue(booleanValue)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(sut.sessionManager as! MockF4SNetworkSessionManager === sessionManager)
        XCTAssertTrue(previousTask.cancelWasCalled)
        assertMockDataTask(sut.dataTask as! MockNetworkTask<[String: String?]>, verb: .patch, url: "/v2/placement/placementUuid")
    }
    
    func test_cancel() {
        let resultJson: [String: String?] = ["true": nil]
        let successResult = F4SNetworkResult.success(resultJson)
        let sut = makeSUT(successResult: successResult)
        let expectation = XCTestExpectation(description: "")
        sut.cancelPlacement("placementUuid") { (result) in
            switch result {
            case .error(_):
                XCTFail("The test was intended to return a success result")
            case .success(let booleanValue):
                XCTAssertTrue(booleanValue)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(sut.sessionManager as! MockF4SNetworkSessionManager === sessionManager)
        XCTAssertTrue(previousTask.cancelWasCalled)
        assertMockDataTask(sut.dataTask as! MockNetworkTask<[String: String?]>, verb: .patch, url: "/v2/placement/placementUuid")
    }
    
    func test_decline() {
        let resultJson: [String: String?] = ["true": nil]
        let successResult = F4SNetworkResult.success(resultJson)
        let sut = makeSUT(successResult: successResult)
        let expectation = XCTestExpectation(description: "")
        sut.declinePlacement("placementUuid") { (result) in
            switch result {
            case .error(_):
                XCTFail("The test was intended to return a success result")
            case .success(let booleanValue):
                XCTAssertTrue(booleanValue)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(sut.sessionManager as! MockF4SNetworkSessionManager === sessionManager)
        XCTAssertTrue(previousTask.cancelWasCalled)
        assertMockDataTask(sut.dataTask as! MockNetworkTask<[String: String?]>, verb: .patch, url: "/v2/placement/placementUuid")
    }

    func test_getAllPlacementsForUser() {
        let placement = F4STimelinePlacement(userUuid: "userUuid", companyUuid: "companyUuid", placementUuid: "placementUuid")
        let successResult = F4SNetworkResult.success([placement])
        let sut = makeSUT(successResult: successResult)
        let expectation = XCTestExpectation(description: "")
        sut.getAllPlacementsForUser() { (result) in
            switch result {
            case .error(_):
                XCTFail("The test was intended to return a success result")
            case .success(let placements):
                XCTAssertEqual(placements.count, 1)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(sut.sessionManager as! MockF4SNetworkSessionManager === sessionManager)
        XCTAssertTrue(previousTask.cancelWasCalled)
        assertMockDataTask(sut.dataTask as! MockNetworkTask<[F4STimelinePlacement]>, verb: .get, url: "/v2/placement")
    }
    
    func test_ratePlacement() {
        let placement = F4STimelinePlacement(userUuid: "userUuid", companyUuid: "companyUuid", placementUuid: "placementUuid")
        let successResult = F4SNetworkResult.success([placement])
        let sut = makeSUT(successResult: successResult)
        XCTAssertThrowsError(try sut.ratePlacement(placementUuid: "placementUuid", rating: 0, completion: { (resut) in }))
    }
    
    // MARK:- helpers
    
    func assertMockDataTask<A:Codable>(_ dataTask: MockNetworkTask<A>, verb: F4SHttpRequestVerb, url: String) {
        XCTAssertTrue(dataTask.resumeWasCalled)
        XCTAssertFalse(dataTask.cancelWasCalled)
        XCTAssertEqual(dataTask.verb, verb)
        XCTAssertTrue(dataTask.url! == URL(string: url)!)
    }
    
    func makeSUT<A:Codable>(successResult: F4SNetworkResult<A>) -> F4SPlacementService {
        let sut = F4SPlacementService(sessionManager: sessionManager)
        sut.dataTask = previousTask
        sut.networkTaskFactory = MockF4SNetworkTaskFactory(userUuid: "userUuid", requiredSuccessResult: successResult)
        return sut
    }
}
