import XCTest
import WorkfinderCommon
@testable import WorkfinderServices

class F4SUserStatusServiceTests: XCTestCase {

    func test_initialise() {
        let sut = F4SUserStatusService(configuration: makeTestConfiguration())
        XCTAssertEqual(sut.apiName, "user/status")
    }
    
    func test_getUserStatus_with_success_result() {
        let sut = F4SUserStatusService(configuration: makeTestConfiguration())
        let returnObject = F4SUserStatus(unreadMessageCount: 9, unratedPlacements: ["uuid1", "uuid2"])
        let requiredResult = F4SNetworkResult.success(returnObject)
        sut.networkTaskfactory = MockF4SNetworkTaskFactory(requiredSuccessResult: requiredResult)
        let expectation = XCTestExpectation(description: "")
        sut.getUserStatus() { (result) in
            switch result {
            case .error(_):
                XCTFail("The test was designed to return a success result")
            case .success(let userStatus):
                XCTAssertEqual(userStatus.unreadMessageCount,9)
                XCTAssertEqual(userStatus.unratedPlacements.count, 2)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func test_beginStatusUpdate() {
        let expectation = XCTestExpectation(description: "notification arrived")
        let sut = F4SUserStatusService(configuration: makeTestConfiguration())
        let returnObject = F4SUserStatus(unreadMessageCount: 9, unratedPlacements: ["uuid1", "uuid2"])
        let requiredResult = F4SNetworkResult.success(returnObject)
        sut.networkTaskfactory = MockF4SNetworkTaskFactory(requiredSuccessResult: requiredResult)
        NotificationCenter.default.addObserver(forName: .f4sUserStatusUpdated, object: nil, queue: nil) { (notification) in
            expectation.fulfill()
            XCTAssertEqual(sut.userStatus!.unreadMessageCount, 9)
        }
        sut.beginStatusUpdate()
        wait(for: [expectation], timeout: 1)
    }

}
