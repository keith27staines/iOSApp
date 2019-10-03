import XCTest
import WorkfinderCommon
@testable import WorkfinderNetworking

class F4SNetworkSessionManagerTests: XCTestCase {
    
    lazy var mockLog: MockF4SAnalyticsAndDebugging = { return MockF4SAnalyticsAndDebugging() }()
    
    func test_interactiveSessionManager() {
        let sut = makeSut()
        let sutWexApiHeaderValue = sut.interactiveSession.configuration.httpAdditionalHeaders?.first(where: { (header) -> Bool in
            (header.key as? String) == "wex.api.key"
        })?.value as? String
        XCTAssertEqual(sutWexApiHeaderValue, "wexApiKey")
    }
    
    func test_smallImageSession() {
        let sut = makeSut()
        XCTAssertEqual(sut.smallImageSession, sut._smallImageSession)
    }
    
    func makeSut() -> F4SNetworkSessionManager {
        return F4SNetworkSessionManager(wexApiKey: "wexApiKey")
    }
}
