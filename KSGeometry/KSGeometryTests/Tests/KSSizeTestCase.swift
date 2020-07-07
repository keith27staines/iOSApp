
import XCTest
@testable import KSGeometry

class KSSizeTestCase: XCTestCase {
    
    func test_initialise() {
        let sut = KSSize(width: 6, height: 7)
        XCTAssertEqual(sut.width, 6)
        XCTAssertEqual(sut.height, 7)
    }
    
    func test_zero() {
        let sut = KSSize.zero
        XCTAssertEqual(sut, KSSize(width: 0, height: 0))
    }
    
    func test_scale() {
        let sut = KSSize(width: 3, height: 4)
        XCTAssertEqual(sut.scaled(by: 3), KSSize(width: 9, height: 12))
    }
}
