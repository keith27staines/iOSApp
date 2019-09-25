import XCTest
import WorkfinderCommon

class F4SUserStatusTests: XCTestCase {

    func test_initialise() {
        let sut = F4SUserStatus(unreadMessageCount: 17, unratedPlacements: ["uuid"])
        XCTAssertEqual(sut.unreadMessageCount,17)
        XCTAssertEqual(sut.unratedPlacements, ["uuid"])
    }

}
