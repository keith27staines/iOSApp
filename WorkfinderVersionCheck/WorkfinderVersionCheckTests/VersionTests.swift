
import XCTest
@testable import WorkfinderVersionCheck

class VersionTests: XCTestCase {
    
    func test_initialise_with_components() {
        let sut = Version(major: 100, minor: 200, revision: 300)
        XCTAssertEqual(sut.major, 100)
        XCTAssertEqual(sut.minor, 200)
        XCTAssertEqual(sut.revision, 300)
    }
    
    func test_initialise_from_invalidStrings() {
        XCTAssertNil(Version(string: nil))
        XCTAssertNil(Version(string: "1rubbish2"))
    }
    
    func test_initialise_from_emptyString() {
        let sut = Version(string: "")
        XCTAssertEqual(sut, Version(major: 0, minor: 0, revision: 0))
    }
    
    func test_equality() {
        let sut1 = Version(string: "3.2.1")
        let sut2 = Version(major: 3, minor: 2, revision: 1)
        XCTAssertEqual(sut1, sut2)
    }
    
    func test_less_than() {
        XCTAssertLessThan(Version(string: "3.2.0")!, Version(string: "3.2.1")!)
        XCTAssertLessThan(Version(string: "3.2.0")!, Version(string: "3.3.0")!)
        XCTAssertLessThan(Version(string: "3.2.0")!, Version(string: "4.2.0")!)
    }
}
