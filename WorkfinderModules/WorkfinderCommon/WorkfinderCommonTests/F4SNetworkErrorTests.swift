import XCTest
@testable import WorkfinderCommon

class F4SNetworkDataErrorTypeTests: XCTestCase {
    
    func test_noData() {
        let type = F4SNetworkDataErrorType.noData
        XCTAssertEqual(type.error(attempting: "something").code, "-1000")
    }
    
    func test_deserialization() {
        let type = F4SNetworkDataErrorType.deserialization(Data())
        XCTAssertEqual(type.error(attempting: "something").code, "-1100")
    }
    
    func test_serialization() {
        let type = F4SNetworkDataErrorType.serialization(["encodable"])
        XCTAssertEqual(type.error(attempting: "something").code, "-1200")
    }
    
    func test_unknown() {
        let type = F4SNetworkDataErrorType.unknownError(nil)
        XCTAssertEqual(type.error(attempting: "something").code, "-1300")
    }
    
    func test_genericErrorWithRetry() {
        let type = F4SNetworkDataErrorType.genericErrorWithRetry
        XCTAssertEqual(type.error(attempting: "something").code, "-1400")
        XCTAssertTrue(type.error(attempting: "").retry)
    }
    
    func test_badUrl() {
        let type = F4SNetworkDataErrorType.badUrl("rubbish")
        XCTAssertEqual(type.error(attempting: "something").code, "-1500")
    }
    
}

class F4SNetworkErrorTests: XCTestCase {
    
    func test_initialise_with_description() {
        let sut = F4SNetworkError(localizedDescription: "localised", attempting: "attempting", retry: true, logError: true, code: 7)
        XCTAssertEqual(sut.code, "7")
        XCTAssertEqual(sut.localizedDescription, "localised")
        XCTAssertEqual(sut.attempting, "attempting")
        XCTAssertEqual(sut.retry, true)
        XCTAssertNil(sut.response)
        XCTAssertNil(sut.localizedFailureReason)
        XCTAssertNil(sut.localizedRecoveryOptions)
       XCTAssertNil(sut.localizedRecoverySuggestion)
    }

    func test_initialise_with_200_response() {
        let url = URL(string: "/url")!
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "http1", headerFields: nil)!
        let sut = F4SNetworkError(response: response, attempting: "something")
        XCTAssertNil(sut)
    }
    
    func test_initialise_with_299_response() {
        let url = URL(string: "/url")!
        let response = HTTPURLResponse(url: url, statusCode: 299, httpVersion: "http1", headerFields: nil)!
        let sut = F4SNetworkError(response: response, attempting: "something")
        XCTAssertNil(sut)
    }
    
    func test_initialise_with_error_response() {
        let url = URL(string: "/url")!
        let r400 = HTTPURLResponse(url: url, statusCode: 400, httpVersion: "http1", headerFields: nil)!
        let r401 = HTTPURLResponse(url: url, statusCode: 401, httpVersion: "http1", headerFields: nil)!
        let r403 = HTTPURLResponse(url: url, statusCode: 403, httpVersion: "http1", headerFields: nil)!
        let r404 = HTTPURLResponse(url: url, statusCode: 404, httpVersion: "http1", headerFields: nil)!
        let r429 = HTTPURLResponse(url: url, statusCode: 429, httpVersion: "http1", headerFields: nil)!
        let r500 = HTTPURLResponse(url: url, statusCode: 500, httpVersion: "http1", headerFields: nil)!
        let r503 = HTTPURLResponse(url: url, statusCode: 503, httpVersion: "http1", headerFields: nil)!
        let r599 = HTTPURLResponse(url: url, statusCode: 599, httpVersion: "http1", headerFields: nil)!
        XCTAssertEqual(F4SNetworkError(response: r400, attempting: "")?.code, "400")
        XCTAssertEqual(F4SNetworkError(response: r401, attempting: "")?.code, "401")
        XCTAssertEqual(F4SNetworkError(response: r403, attempting: "")?.code, "403")
        XCTAssertEqual(F4SNetworkError(response: r404, attempting: "")?.code, "404")
        XCTAssertEqual(F4SNetworkError(response: r429, attempting: "")?.code, "429")
        XCTAssertEqual(F4SNetworkError(response: r500, attempting: "")?.code, "500")
        XCTAssertEqual(F4SNetworkError(response: r503, attempting: "")?.code, "503")
        XCTAssertEqual(F4SNetworkError(response: r599, attempting: "")?.code, "599")
        
        XCTAssertEqual(F4SNetworkError(response: r400, attempting: "")?.retry, false)
        XCTAssertEqual(F4SNetworkError(response: r401, attempting: "")?.retry, false)
        XCTAssertEqual(F4SNetworkError(response: r403, attempting: "")?.retry, false)
        XCTAssertEqual(F4SNetworkError(response: r404, attempting: "")?.retry, false)
        XCTAssertEqual(F4SNetworkError(response: r429, attempting: "")?.retry, true)
        XCTAssertEqual(F4SNetworkError(response: r500, attempting: "")?.retry, false)
        XCTAssertEqual(F4SNetworkError(response: r503, attempting: "")?.retry, true)
        XCTAssertEqual(F4SNetworkError(response: r599, attempting: "")?.retry, false)
    }

}
