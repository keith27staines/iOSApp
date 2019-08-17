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
    
    func test_initialise() {
        let sut = F4SNetworkError(localizedDescription: "localised", attempting: "attempting", retry: true, logError: true, code: 7)
        XCTAssertEqual(sut.code, "7")
        XCTAssertEqual(sut.localizedDescription, "localised")
        XCTAssertEqual(sut.attempting, "attempting")
        XCTAssertEqual(sut.retry, true)
        XCTAssertNil(sut.response)
        XCTAssertNil(sut.localizedFailureReason)
    }
    

}
