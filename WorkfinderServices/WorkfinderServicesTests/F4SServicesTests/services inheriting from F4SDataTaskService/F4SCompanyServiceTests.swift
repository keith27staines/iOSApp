import XCTest
import WorkfinderCommon
@testable import WorkfinderServices

class F4SCompanyServiceTests: XCTestCase {

    func test_initialise() {
        let sut = F4SCompanyService(configuration: makeTestConfiguration())
        XCTAssertEqual(sut.apiName, "company")
    }
    
    func test_getCompany() {
        let sut = F4SCompanyService(configuration: makeTestConfiguration())
        let requiredValue = CompanyJson()
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

class CompanyJsonTests: XCTestCase {
    func test_urls_when_nil() {
        let sut = CompanyJson()
        XCTAssertNil(sut.linkedInUrlString)
        XCTAssertNil(sut.duedilUrlString)
    }
    
    func test_rulsWhenNotNil() {
        var sut = CompanyJson()
        sut.linkedInUrlString = "linkedin"
        sut.duedilUrlString = "duedil"
        XCTAssertNotNil(sut.linkedInUrlString)
        XCTAssertNotNil(sut.duedilUrlString)
    }
}
