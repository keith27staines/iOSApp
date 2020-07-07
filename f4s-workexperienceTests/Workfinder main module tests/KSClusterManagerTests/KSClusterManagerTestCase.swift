
import XCTest
import KSGeometry
import KSQuadTree
import GoogleMaps
@testable import Workfinder

class KSClusterManagerTestCase: XCTestCase {
    
    lazy var mapView: GMSMapView = {
        GMSServices.provideAPIKey(GoogleApiKeys.googleApiKey)
        return GMSMapView()
    }()
    
    let bounds = KSRect(x: -100, y: -100, width: 200, height: 200)
    let testPinBounds = KSRect(x: -0.1, y: -0.1, width: 4.2, height: 4.2)
    let testPins: [KSPin] = [
        KSPin(id: 0, point: KSPoint(x: 0, y: 0)),
        KSPin(id: 1, point: KSPoint(x: 1, y: 0)),
        KSPin(id: 2, point: KSPoint(x: 2, y: 0)),
        KSPin(id: 3, point: KSPoint(x: 3, y: 0)),
        KSPin(id: 4, point: KSPoint(x: 4, y: 0)),
        KSPin(id: 5, point: KSPoint(x: 0, y: 1)),
        KSPin(id: 6, point: KSPoint(x: 1, y: 1)),
        KSPin(id: 7, point: KSPoint(x: 2, y: 1)),
        KSPin(id: 8, point: KSPoint(x: 3, y: 1)),
        KSPin(id: 9, point: KSPoint(x: 4, y: 1)),
        KSPin(id: 10, point: KSPoint(x: 0, y: 2)),
        KSPin(id: 11, point: KSPoint(x: 1, y: 2)),
        KSPin(id: 12, point: KSPoint(x: 2, y: 2)),
        KSPin(id: 13, point: KSPoint(x: 3, y: 2)),
        KSPin(id: 14, point: KSPoint(x: 4, y: 2)),
        KSPin(id: 15, point: KSPoint(x: 0, y: 3)),
        KSPin(id: 16, point: KSPoint(x: 1, y: 3)),
        KSPin(id: 17, point: KSPoint(x: 2, y: 3)),
        KSPin(id: 18, point: KSPoint(x: 3, y: 3)),
        KSPin(id: 19, point: KSPoint(x: 4, y: 3)),
        KSPin(id: 20, point: KSPoint(x: 0, y: 4)),
        KSPin(id: 20, point: KSPoint(x: 1, y: 4)),
        KSPin(id: 20, point: KSPoint(x: 2, y: 4)),
        KSPin(id: 20, point: KSPoint(x: 3, y: 4)),
        KSPin(id: 20, point: KSPoint(x: 4, y: 4)),
    ]
    
    func test_initialise() {
        let sut = KSGMClusterManager(mapView: mapView)
        XCTAssertEqual(sut.pinsQuadTree.count(), 0)
        XCTAssertEqual(sut.clustersQuadTree.count(), 0)
        XCTAssertEqual(sut.pins.count, 0)
    }
    
    func test_insertPin() {
        let sut = KSGMClusterManager(mapView: mapView)
        sut.insertObject(x: 0, y: 0, object: "")
        XCTAssertEqual(sut.pinsQuadTree.count(), 1)
        XCTAssertEqual(sut.pins.count, 1)
    }
    
    func test_insertPins() {
        let sut = makeSUT(pins: testPins)
        XCTAssertEqual(sut.pinsQuadTree.count(), testPins.count)
        XCTAssertEqual(sut.pins.count, testPins.count)
    }
    
    func test_clear() {
        let sut = makeSUT(pins: testPins)
        sut.clear()
        XCTAssertEqual(sut.pinsQuadTree.count(), 0)
        XCTAssertEqual(sut.pins.count, 0)
    }
    
    func makeSUT(pins: [KSPin]) -> KSGMClusterManager {
        let sut = KSGMClusterManager(mapView: mapView)
        testPins.forEach { (pin) in
            sut.insertObject(x: pin.x, y: pin.y, object: "")
        }
        return sut
    }
}
