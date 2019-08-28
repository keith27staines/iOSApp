import XCTest
import WorkfinderCommon
@testable import WorkfinderServices

class F4SPlacementApplicationServiceTests: XCTestCase {

    func test_initialise() {
        let sut = F4SPlacementApplicationService()
        XCTAssertEqual(sut.apiName, "placement")
    }
    
    func test_apply() {
        let sut = F4SPlacementApplicationService()
        let requiredValue = F4SPlacementJson(uuid: "uuid", user: "userUuid", company: "companyUuid", vendor: "vendorUuid", interests: nil)
        let requiredResult = F4SNetworkResult.success(requiredValue)
        let expectation  = XCTestExpectation(description: "")
        sut.networkTaskfactory = MockF4SNetworkTaskFactory(requiredSuccessResult:
            requiredResult)
        let applyJson = F4SCreatePlacementJson(user: "userUuid", roleUuid: "roleUuid", company: "companyUuid", vendor: "vendorUuid", interests: [])
        sut.apply(with: applyJson) { (result) in
            switch result {
            case .error(_):
                XCTFail("This test was designed to return a success result")
            case .success(let placement):
                expectation.fulfill()
                XCTAssertEqual(placement.userUuid,"userUuid")
            }
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func test_update() {
        let sut = F4SPlacementApplicationService()
        let requiredValue = F4SPlacementJson(uuid: "uuid", user: "userUuid", company: "companyUuid", vendor: "vendorUuid", interests: nil)
        let requiredResult = F4SNetworkResult.success(requiredValue)
        let expectation  = XCTestExpectation(description: "")
        sut.networkTaskfactory = MockF4SNetworkTaskFactory(requiredSuccessResult:
            requiredResult)
        let patchJson = F4SPlacementJson(uuid: "placementUuid", user: "userUuid", company: "companyUuid", vendor: "vendorUuid", interests: nil)
        sut.update(uuid: "placementUuid", with: patchJson) { (result) in
            switch result {
            case .error(_):
                XCTFail("This test was designed to return a success result")
            case .success(let placement):
                expectation.fulfill()
                XCTAssertEqual(placement.userUuid,"userUuid")
            }
        }
        wait(for: [expectation], timeout: 1)
    }
    


}
