
import XCTest
import WorkfinderCommon

class DeeplinkInfoTests: XCTestCase {

    func test_initialise() {
        var sut = DeeplinkDispatchInfo(source: .deeplink, objectType: .application, action: .view(<#T##F4SUUID#>))
        XCTAssertEqual(sut.objectId, "UUID")
        XCTAssertEqual(sut.objectType, .application)
        XCTAssertEqual(sut.source, .deeplink)
        XCTAssertEqual(sut.action, .list)
    }

}
