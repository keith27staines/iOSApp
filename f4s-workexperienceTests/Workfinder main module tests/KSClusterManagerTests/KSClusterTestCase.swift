
import XCTest
import KSGeometry
@testable import Workfinder

fileprivate let pinID = 7
fileprivate let clusterID = 777

class KSClusterTestCase: XCTestCase {
    
    let centerPin = KSPin(id: pinID, x: 1, y: 0)
    
    func test_cluster_initialise() {
        let sut = makeSUT(id: clusterID)
        XCTAssertEqual(sut.id, clusterID)
        XCTAssertEqual(sut.centerPin, centerPin)
        XCTAssertEqual(sut.pins.first, centerPin)
        XCTAssertEqual(sut.count, 1)
        XCTAssertEqual(sut.x, centerPin.x)
        XCTAssertEqual(sut.y, centerPin.y)
    }
    
    func test_equality_and_hash() {
        let sut1 = makeSUT(id: clusterID)
        let sut2 = makeSUT(id: clusterID+1)
        XCTAssertNotEqual(sut1, sut2)
        XCTAssertNotEqual(sut1.hashValue, sut2.hashValue)
    }
    
    func test_addPin_not_same() {
        let sut = makeSUT(id: clusterID)
        sut.addPin(KSPin(id: pinID, x: 0, y: 0))
        XCTAssertEqual(sut.count, 1)
    }
    
    func test_addPin_same() {
        let sut = makeSUT(id: clusterID)
        sut.addPin(centerPin)
        XCTAssertEqual(sut.count, 1)
    }
    
    func test_catchementRectangleWithSize() {
        let size = KSSize(width: 2, height: 3)
        let sut = makeSUT(id: clusterID)
        XCTAssertEqual(
            sut.catchementRectangle(size: size),
            KSRect(center: sut.centerPin.point, size: size)
        )
    }
    
    func makeSUT(id: Int) -> KSCluster {
        KSCluster(id: id, centerPin: centerPin)
    }

    
}
