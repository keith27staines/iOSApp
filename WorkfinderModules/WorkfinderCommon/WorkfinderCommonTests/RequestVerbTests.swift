
import XCTest
@testable import WorkfinderCommon

class RequestVerbTests: XCTestCase {

    func test_init_with_name() {
        XCTAssertEqual(RequestVerb(verbName: "GET")?.name, "GET")
        XCTAssertEqual(RequestVerb(verbName: "PUT")?.name, "PUT")
        XCTAssertEqual(RequestVerb(verbName: "PATCH")?.name, "PATCH")
        XCTAssertEqual(RequestVerb(verbName: "POST")?.name, "POST")
        XCTAssertEqual(RequestVerb(verbName: "DELETE")?.name, "DELETE")
    }

}
