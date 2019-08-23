import XCTest
import WorkfinderCommon
import WorkfinderNetworking
@testable import WorkfinderServices

class F4SCompanyDatabaseMetadataServiceTests: XCTestCase {

    func test_initialise() {
        let sut = F4SCompanyDatabaseMetadataService()
        XCTAssertEqual(sut.apiName, "company/dump/full")
    }
    
    func test_getDatabaseMetadata() {
        let sut = F4SCompanyDatabaseMetadataService()
        let date = Date()
        let expectedMetadata = F4SCompanyDatabaseMetaData(created: date, urlString: "urlString", errors: nil)
        let requiredResult = F4SNetworkResult.success(expectedMetadata)
        sut.networkTaskfactory = MockF4SNetworkTaskFactory(requiredSuccessResult: requiredResult)
        let expectation = XCTestExpectation(description: "")
        sut.getDatabaseMetadata { (result) in
            switch result {
            case .error(_):
                XCTFail("The test was designed to return a success result")
            case .success(let metadata):
                XCTAssertEqual(metadata.urlString!, expectedMetadata.urlString!)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

}
