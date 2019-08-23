import XCTest
import WorkfinderCommon
import WorkfinderNetworking
@testable import WorkfinderServices

class F4SMessageActionServiceTests: XCTestCase {

    func test_initialise() {
        let threadUuid = "threadUuid"
        let sut = F4SMessageActionService(threadUuid: threadUuid)
        XCTAssertEqual(sut.apiName, "messaging/\(threadUuid)/user_action")
    }

}
