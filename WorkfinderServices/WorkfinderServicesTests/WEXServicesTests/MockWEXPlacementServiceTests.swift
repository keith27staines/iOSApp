import XCTest

import WorkfinderCommon
@testable import WorkfinderServices

class MockWEXPlacementServiceTests: XCTestCase {

    func test_injected_resultForCreate() {
        let placementJson = WEXPlacementJson(uuid: "123456")
        let result = WEXResult<WEXPlacementJson,WEXError>.success(placementJson)
        let sut = MockWEXPlacementService(createResult: result)
        switch sut.resultForCreate! {
        case .success(let json):
            XCTAssertEqual(placementJson.uuid!, json.uuid!)
        case .failure(_):
            XCTFail("The injected result is not what was expected")
        }
    }
    
    public func test_completion_called_in_createPlacement() {
        let expectation = XCTestExpectation(description: "completion_called")
        let createJson = WEXCreatePlacementJson(user: "", roleUuid: "", company: "", vendor: "", interests: [])
        let resultJson = WEXPlacementJson(uuid: "1234")
        let result = WEXResult<WEXPlacementJson,WEXError>.success(resultJson)
        let sut = MockWEXPlacementService(createResult: result)
        sut.createPlacement(with: createJson) { (result) in
            expectation.fulfill()
            switch result {
            case .success(let returnedPlacementJson):
                XCTAssertEqual(returnedPlacementJson.uuid!, resultJson.uuid!)
            case .failure(_):
                XCTFail("The test was designed to return a success result")
            }
        }
        wait(for: [expectation], timeout: 0.1)
        XCTAssertTrue(sut.createCount==1)
    }
    
    public func test_completion_called_in_patchPlacement() {
        let expectation = XCTestExpectation(description: "completion_called")
        let placementJson = WEXPlacementJson(uuid: "1234")
        let result = WEXResult<WEXPlacementJson,WEXError>.success(placementJson)
        let sut = MockWEXPlacementService(patchResult: result)
        sut.patchPlacement(uuid: "1234", with: placementJson) { (result) in
            expectation.fulfill()
            switch result {
            case .success(let returnedPlacementJson):
                XCTAssertEqual(returnedPlacementJson.uuid!, placementJson.uuid)
                
            case .failure(_):
                XCTFail("The test was designed to return a success result")
            }
        }
        wait(for: [expectation], timeout: 0.1)
        XCTAssertTrue(sut.patchCount==1)
    }

}
