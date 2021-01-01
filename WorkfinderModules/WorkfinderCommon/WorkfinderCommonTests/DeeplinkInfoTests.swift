
import XCTest
import WorkfinderCommon

class DeeplinkInfoTests: XCTestCase {

    func test_initialise() {
        let sut = DeeplinkRoutingInfo(source: .deeplink, objectType: .placement, objectId: "1234", action: .open)
        XCTAssertEqual(sut.objectType, .placement)
        XCTAssertEqual(sut.source, .deeplink)
        XCTAssertEqual(sut.objectId, "1234")
        XCTAssertEqual(sut.action, .open)
    }

}
