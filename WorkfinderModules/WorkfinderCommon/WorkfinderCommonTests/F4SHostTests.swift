
import XCTest
@testable import WorkfinderCommon

class F4SHostTests: XCTestCase {
    
    func test_initialise() {
        
        let sut = Host(
            uuid: "hostUuid",
            displayName: "displayName",
            linkedinUrlString: "linkedinUrl",
            photoUrlString: "photoUrl",
            summary: "summary")
        
        XCTAssertEqual(sut.uuid, "hostUuid")
        XCTAssertEqual(sut.displayName, "displayName")
        XCTAssertEqual(sut.linkedinUrlString, "linkedinUrl")
        XCTAssertEqual(sut.photoUrlString, "photoUrl")
        XCTAssertEqual(sut.description, "summary")
    }
}



