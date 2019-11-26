import XCTest

import WorkfinderCommon
@testable import WorkfinderServices

class MockF4SPlacementApplicationServiceTests: XCTestCase {

    func test_injected_resultForCreate() {
        let placementJson = F4SPlacementJson(uuid: "123456")
        let result = F4SNetworkResult<F4SPlacementJson>.success(placementJson)
        let sut = MockF4SPlacementApplicationService(createResult: result)
        switch sut.resultForCreate! {
        case .success(let json):
            XCTAssertEqual(placementJson.uuid!, json.uuid!)
        case .error(_):
            XCTFail("The injected result is not what was expected")
        }
    }
    
    public func test_completion_called_in_createPlacement() {
        let expectation = XCTestExpectation(description: "completion_called")
        let createJson = F4SCreatePlacementJson(user: "", roleUuid: "", company: "", hostUuid: "hostUuid", vendor: "", interests: [])
        let resultJson = F4SPlacementJson(uuid: "1234")
        let result = F4SNetworkResult<F4SPlacementJson>.success(resultJson)
        let sut = MockF4SPlacementApplicationService(createResult: result)
        sut.apply(with: createJson) { (result) in
            expectation.fulfill()
            switch result {
            case .success(let returnedPlacementJson):
                XCTAssertEqual(returnedPlacementJson.uuid!, resultJson.uuid!)
            case .error(_):
                XCTFail("The test was designed to return a success result")
            }
        }
        wait(for: [expectation], timeout: 0.1)
        XCTAssertTrue(sut.createCount==1)
    }
    
    public func test_completion_called_in_patchPlacement() {
        let expectation = XCTestExpectation(description: "completion_called")
        let placementJson = F4SPlacementJson(uuid: "1234")
        let result = F4SNetworkResult<F4SPlacementJson>.success(placementJson)
        let sut = MockF4SPlacementApplicationService(patchResult: result)
        sut.update(uuid: "1234", with: placementJson) { (result) in
            expectation.fulfill()
            switch result {
            case .success(let returnedPlacementJson):
                XCTAssertEqual(returnedPlacementJson.uuid!, placementJson.uuid)
                
            case .error(_):
                XCTFail("The test was designed to return a success result")
            }
        }
        wait(for: [expectation], timeout: 0.1)
        XCTAssertTrue(sut.patchCount==1)
    }

}
