import XCTest
import WorkfinderCommon
@testable import WorkfinderNetworking

class F4SDataTaskServiceTests: XCTestCase {

    func test_initialise_with_no_additional_headers() {
        let expectedHeaders: [String: String] = ["wex.api.key": ""]
        let sut = F4SDataTaskService(baseURLString: "baseUrl", apiName: "apiName")
        
        XCTAssertEqual(sut.apiName, "apiName")
        XCTAssertEqual(sut.baseUrl, URL(string: "baseUrl"))
        XCTAssertEqual(sut.url, URL(string: "baseUrl/apiName"))
        XCTAssertEqual(sut.session.configuration.httpAdditionalHeaders as? [String: String], expectedHeaders)
    }
    
    func test_initialise_with_additional_headers() {
        let additionalHeaders: [String: String] = ["AdditionalHeader1" : "AdditionalHeader1", "wex.api.key": "wexApiKey"]
        let expectedHeaders: [String: String] = [
            "wex.api.key": "wexApiKey",
            "AdditionalHeader1" : "AdditionalHeader1"
        ]
        let sut = F4SDataTaskService(baseURLString: "baseUrl", apiName: "apiName", additionalHeaders: additionalHeaders)

        XCTAssertEqual(sut.apiName, "apiName")
        XCTAssertEqual(sut.baseUrl, URL(string: "baseUrl"))
        XCTAssertEqual(sut.url, URL(string: "baseUrl/apiName"))
        XCTAssertEqual(sut.session.configuration.httpAdditionalHeaders as? [String: String], expectedHeaders)
    }
    
    func test_add_relativeUrl() {
        let sut = F4SDataTaskService(baseURLString: "baseUrl", apiName: "apiName")
        sut.relativeUrlString = "relativeUrl"
        XCTAssertEqual(sut.url, URL(string: "baseUrl/apiName/relativeUrl"))
    }
    
    func test_cancel() {
        
    }
    


}

class MockTask : F4SNetworkTask {
    var cancelled: Bool = false
    var resumeWasCalled: Bool = false
    
    func cancel() {
        cancelled = true
    }
    
    func resume() {
        resumeWasCalled = true
    }
    
    
}
