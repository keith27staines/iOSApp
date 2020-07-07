
import XCTest
@testable import KSGeometry

class KSPointTestCase: XCTestCase {

    func test_initialise_with_coordinates() {
        let sut = KSPoint(x:1,y:2)
        XCTAssertEqual(sut.x, 1)
        XCTAssertEqual(sut.y, 2)
    }
    
    func test_zero() {
        let sut = KSPoint.zero
        XCTAssertEqual(sut, KSPoint(x: 0, y: 0))
    }
    
    func test_distance() {
        let p1 = KSPoint.zero
        let p2 = KSPoint(x: 3, y: 4)
        XCTAssertEqual(p1.distance2From(p2), 25)
        XCTAssertEqual(p1.distance2From(p2), p2.distance2From(p1))
    }

}
