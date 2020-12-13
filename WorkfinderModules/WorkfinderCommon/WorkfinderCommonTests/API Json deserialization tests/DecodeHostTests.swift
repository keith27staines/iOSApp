
import XCTest
@testable import WorkfinderCommon

class HostTests: XCTestCase {
    
    func test_initialise() {
        
        let sut = HostJson(
            uuid: "hostUuid",
            displayName: "displayName",
            linkedinUrlString: "linkedinUrl",
            photoUrlString: "photoUrl",
            summary: "summary")
        
        XCTAssertEqual(sut.uuid, "hostUuid")
        XCTAssertEqual(sut.fullName, "displayName")
        XCTAssertEqual(sut.linkedinUrlString, "linkedinUrl")
        XCTAssertEqual(sut.photoUrlString, "photoUrl")
        XCTAssertEqual(sut.description, "summary")
    }
}



