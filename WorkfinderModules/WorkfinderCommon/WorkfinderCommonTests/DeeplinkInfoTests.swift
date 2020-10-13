
import XCTest
import WorkfinderCommon

class DeeplinkInfoTests: XCTestCase {

    func test_initialise() {
        var sut = DeeplinkDispatchInfo(source: .deeplink, objectType: .application, action: .open("UUID"))
        XCTAssertEqual(sut.objectType, .application)
        XCTAssertEqual(sut.source, .deeplink)
    }

}
