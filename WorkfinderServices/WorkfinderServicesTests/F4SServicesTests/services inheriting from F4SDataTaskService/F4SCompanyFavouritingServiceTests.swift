import XCTest
import WorkfinderCommon
@testable import WorkfinderServices

class F4SCompanyFavouritingServiceTests: XCTestCase {

    func test_initialise() {
        let sut = F4SCompanyFavouritingService(configuration: makeTestConfiguration())
        XCTAssertEqual(sut.apiName, "favourite")
    }

    func test_favourite_with_success_result() {
        let sut = F4SCompanyFavouritingService(configuration: makeTestConfiguration())
        let returnObject = F4SShortlistJson(uuid: "uuid", companyUuid: "companyUuid", errors: nil)
        let requiredResult = F4SNetworkResult.success(returnObject)
        sut.networkTaskfactory = MockF4SNetworkTaskFactory(requiredSuccessResult: requiredResult)
        let expectation = XCTestExpectation(description: "")
        sut.favourite(companyUuid: "companyUuid") { (result) in
            switch result {
            case .error(_):
                XCTFail("The test was designed to return a success result")
            case .success(let favourite):
                XCTAssertEqual(favourite.companyUuid,"companyUuid")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func test_favourite_with_error_result() {
        let sut = F4SCompanyFavouritingService(configuration: makeTestConfiguration())
        sut.networkTaskfactory = MockF4SNetworkTaskFactory<F4SShortlistJson>(requiredNetworkError: F4SNetworkError(error: F4SError.genericError("test error"), attempting: ""))
        let expectation = XCTestExpectation(description: "")
        sut.favourite(companyUuid: "companyUuid") { (result) in
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
    
    func test_unfavourite() {
        let shortlistUuid = "shortlistUuid"
        let sut = F4SCompanyFavouritingService(configuration: makeTestConfiguration())
        let requiredResult = F4SNetworkResult.success([shortlistUuid])
        sut.networkTaskfactory = MockF4SNetworkTaskFactory(requiredSuccessResult: requiredResult)
        let expectation = XCTestExpectation(description: "")
        sut.unfavourite(shortlistUuid: shortlistUuid) { (result) in
            switch result {
            case .error(_):
                XCTFail("The test was designed to return a success result")
            case .success(let uuid):
                XCTAssertEqual(uuid, shortlistUuid)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    
}
