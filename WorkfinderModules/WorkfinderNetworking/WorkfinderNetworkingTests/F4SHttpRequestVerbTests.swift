import XCTest
import WorkfinderCommon
@testable import WorkfinderNetworking

class F4SHttpRequestVerbTests: XCTestCase {

    func test_names() {
        XCTAssertEqual(RequestVerb.get.name, "GET")
        XCTAssertEqual(RequestVerb.post.name, "POST")
        XCTAssertEqual(RequestVerb.patch.name, "PATCH")
        XCTAssertEqual(RequestVerb.put.name, "PUT")
        XCTAssertEqual(RequestVerb.delete.name, "DELETE")
    }
    
    func test_initialise_from_verb_name() {
        XCTAssertEqual(RequestVerb(verbName: "get")?.name, "GET")
        XCTAssertEqual(RequestVerb(verbName: "PosT")?.name, "POST")
        XCTAssertEqual(RequestVerb(verbName: "patch")?.name, "PATCH")
        XCTAssertEqual(RequestVerb(verbName: "pUt")?.name, "PUT")
        XCTAssertEqual(RequestVerb(verbName: "delete")?.name, "DELETE")
        XCTAssertNil(RequestVerb(verbName: "xyz"))
    }
}
