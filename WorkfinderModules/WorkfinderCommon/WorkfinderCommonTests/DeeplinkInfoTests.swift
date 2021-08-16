
import XCTest
import WorkfinderCommon

class DeeplinkInfoTests: XCTestCase {

    func test_initialise() {
        let sut = DeeplinkRoutingInfo(source: .deeplink, objectType: .placement, objectId: "1234", queryItems: [:])
        XCTAssertEqual(sut.objectType, .placement)
        XCTAssertEqual(sut.source, .deeplink)
        XCTAssertEqual(sut.objectId, "1234")
        XCTAssertEqual(sut.action, .open)
    }
    
    func test_initialise_with_workfinderapp_with_uuid() {
        let url = URL(string: "workfinderapp://reviews/1234?query1=a&query2=b")!
        let sut = DeeplinkRoutingInfo(deeplinkUrl: url)
        XCTAssertEqual(sut?.objectType, .review)
        XCTAssertEqual(sut?.objectId, "1234")
        XCTAssertEqual(sut?.queryItems["query1"], "a")
        XCTAssertEqual(sut?.queryItems["query2"], "b")
    }

    func test_initialise_with_workfinderapp_without_uuid() {
        let url = URL(string: "workfinderapp://reviews/?query1=a&query2=b")!
        let sut = DeeplinkRoutingInfo(deeplinkUrl: url)
        XCTAssertEqual(sut?.objectType, .review)
        XCTAssertNil(sut?.objectId)
        XCTAssertEqual(sut?.queryItems["query1"], "a")
        XCTAssertEqual(sut?.queryItems["query2"], "b")
    }

    func test_initialise_with_workfinder_with_uuid() {
        let url = URL(string: "https://develop.workfinder.com/reviews/1234?query1=a&query2=b")!
        let sut = DeeplinkRoutingInfo(deeplinkUrl: url)
        XCTAssertEqual(sut?.objectType, .review)
        XCTAssertEqual(sut?.objectId, "1234")
        XCTAssertEqual(sut?.queryItems["query1"], "a")
        XCTAssertEqual(sut?.queryItems["query2"], "b")
    }

    func test_initialise_with_workfinder_without_uuid() {
        let url = URL(string: "https://develop.workfinder.com/reviews?query1=a&query2=b")!
        let sut = DeeplinkRoutingInfo(deeplinkUrl: url)
        XCTAssertEqual(sut?.objectType, .review)
        XCTAssertNil(sut?.objectId)
        XCTAssertEqual(sut?.queryItems["query1"], "a")
        XCTAssertEqual(sut?.queryItems["query2"], "b")
    }
    
    func test_initialise_with_student_dashboard_url() {
        let url = URL(string: "https://develop.workfinder.com/students/dashboard/something-else")!
        let sut = DeeplinkRoutingInfo(deeplinkUrl: url)
        XCTAssertEqual(sut?.objectType, .studentDashboard)
        XCTAssertNil(sut?.objectId)
    }

}
