
import XCTest
import KSGeometry
@testable import Workfinder

class KSPinTestCase: XCTestCase {
    
    func test_pin_initialise_with_point() {
        let sut = KSPin(id: 7, point: KSPoint(x: 1, y: 2))
        XCTAssertEqual(sut.id, 7)
        XCTAssertEqual(sut.point, KSPoint(x: 1, y: 2))
    }
    
    func test_pin_initialise_with_coordinates() {
        XCTAssertEqual(KSPin(id: 7, x: 1, y: 2), KSPin(id: 7, point: KSPoint(x: 1, y: 2)))
    }
}
