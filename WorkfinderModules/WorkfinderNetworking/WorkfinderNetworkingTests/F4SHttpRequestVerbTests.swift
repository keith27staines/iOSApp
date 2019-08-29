import XCTest
@testable import WorkfinderNetworking

class F4SHttpRequestVerbTests: XCTestCase {

    func test_names() {
        XCTAssertEqual(F4SHttpRequestVerb.get.name, "GET")
        XCTAssertEqual(F4SHttpRequestVerb.post.name, "POST")
        XCTAssertEqual(F4SHttpRequestVerb.patch.name, "PATCH")
        XCTAssertEqual(F4SHttpRequestVerb.put.name, "PUT")
        XCTAssertEqual(F4SHttpRequestVerb.delete.name, "DELETE")
    }
    
    func test_initialise_from_verb_name() {
        XCTAssertEqual(F4SHttpRequestVerb(verbName: "get")?.name, "GET")
        XCTAssertEqual(F4SHttpRequestVerb(verbName: "PosT")?.name, "POST")
        XCTAssertEqual(F4SHttpRequestVerb(verbName: "patch")?.name, "PATCH")
        XCTAssertEqual(F4SHttpRequestVerb(verbName: "pUt")?.name, "PUT")
        XCTAssertEqual(F4SHttpRequestVerb(verbName: "delete")?.name, "DELETE")
        XCTAssertNil(F4SHttpRequestVerb(verbName: "xyz"))
    }
}
