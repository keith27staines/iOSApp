import XCTest
import WorkfinderCommon
@testable import WorkfinderServices

class F4SPartnerServiceTests: XCTestCase {

    func test_initialise() {
        let sut = F4SPartnerService(configuration: makeTestConfiguration())
        XCTAssertEqual(sut.apiName, "partner")
    }
    
    func test_getPartners_with_success_result() {
        let sut = F4SPartnerService(configuration: makeTestConfiguration())
        let returnObject = [F4SPartner(uuid: "partnerUuid", name: "partnerName")]
        let requiredResult = F4SNetworkResult.success(returnObject)
        sut.networkTaskfactory = MockF4SNetworkTaskFactory(requiredSuccessResult: requiredResult)
        let expectation = XCTestExpectation(description: "")
        sut.getPartners() { (result) in
            switch result {
            case .error(_):
                XCTFail("The test was designed to return a success result")
            case .success(let partners):
                XCTAssertEqual(partners.count,1)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func test_getPartners_with_error_result() {
        let sut = F4SPartnerService(configuration: makeTestConfiguration())
        let error = F4SNetworkError(error: F4SError.genericError("test error"), attempting: "")
        sut.networkTaskfactory = MockF4SNetworkTaskFactory<[F4SPartner]>(requiredNetworkError: error)
        let expectation = XCTestExpectation(description: "")
        sut.getPartners() { (result) in
            switch result {
            case .error(_):
                break
            case .success(_):
                XCTFail("The test was designed to return an error result")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

}
