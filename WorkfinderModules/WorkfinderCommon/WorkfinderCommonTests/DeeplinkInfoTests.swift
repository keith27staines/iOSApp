
import XCTest
import WorkfinderCommon

class DeeplinkInfoTests: XCTestCase {

    func test_initialise() {
        let sut = DeeplinkRoutingInfo(source: .deeplink, objectType: .placement, objectId: "1234", action: .open, queryItems: [:])
        XCTAssertEqual(sut.objectType, .placement)
        XCTAssertEqual(sut.source, .deeplink)
        XCTAssertEqual(sut.objectId, "1234")
        XCTAssertEqual(sut.action, .open)
    }
    
    func test_initialise_with_workfinderapp() {
        let url = URL(string: "workfinderapp://reviews/1234?query1=a&query2=b")!
        let sut = DeeplinkRoutingInfo(deeplinkUrl: url)
        XCTAssertEqual(sut?.objectType, .review)
        XCTAssertEqual(sut?.objectId, "1234")
        XCTAssertEqual(sut?.queryItems["query1"], "a")
        XCTAssertEqual(sut?.queryItems["query2"], "b")
    }
    
    func test_initialise_with_workfinder.com() {
        let url = URL(string: "https://develop.workfinder.com/reviews/1234?query1=a&query2=b")!
        let sut = DeeplinkRoutingInfo(deeplinkUrl: url)
        XCTAssertEqual(sut?.objectType, .review)
        XCTAssertEqual(sut?.objectId, "1234")
        XCTAssertEqual(sut?.queryItems["query1"], "a")
        XCTAssertEqual(sut?.queryItems["query2"], "b")
    }

}
