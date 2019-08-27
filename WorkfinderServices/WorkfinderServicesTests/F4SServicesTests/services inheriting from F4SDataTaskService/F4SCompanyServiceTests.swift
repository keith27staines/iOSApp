import XCTest
import WorkfinderCommon
@testable import WorkfinderServices

class F4SCompanyServiceTests: XCTestCase {

    func test_initialise() {
        let sut = F4SCompanyService()
        XCTAssertEqual(sut.apiName, "company")
    }
    
    func test_getCompany() {
        let sut = F4SCompanyService()
        let requiredValue = F4SCompanyJson()
        let requiredResult = F4SNetworkResult.success(requiredValue)
        sut.networkTaskfactory = MockF4SNetworkTaskFactory(requiredSuccessResult:
                    requiredResult)
        let expectation = XCTestExpectation(description: "")
        sut.getCompany(uuid: "companyUuid") { (result) in
            XCTAssertEqual(sut.url.lastPathComponent, "companyUuid")
            switch result {
            case .error(_):
                XCTFail("This test was designed to return a success result")
            case .success(_):
                break
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

}
