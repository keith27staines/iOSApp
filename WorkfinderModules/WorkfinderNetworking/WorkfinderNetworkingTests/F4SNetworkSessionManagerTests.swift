import XCTest
import WorkfinderCommon
@testable import WorkfinderNetworking

class F4SNetworkSessionManagerTests: XCTestCase {
    
    lazy var mockLog: MockF4SAnalyticsAndDebugging = { return MockF4SAnalyticsAndDebugging() }()

    func test_interactiveSession() {
        let sut = makeSUT()
        XCTAssertEqual(sut.interactiveSession, sut._interactiveSession)
    }
    
    func test_smallImageSession() {
        let sut = makeSUT()
        XCTAssertEqual(sut.smallImageSession, sut._smallImageSession)
    }
    
    func makeSUT() -> F4SNetworkSessionManager {
        return F4SNetworkSessionManager()
    }
    
}
