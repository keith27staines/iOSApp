import XCTest
import WorkfinderCommon
@testable import WorkfinderServices




class F4STemplateServiceTests: XCTestCase {
    
    func test_initialise() {
        let sut = F4STemplateService(configuration: makeTestConfiguration())
        XCTAssertEqual(sut.apiName, "cover-template")
    }
    
    func test_getTemplate() {
        let sut = F4STemplateService(configuration: makeTestConfiguration())
        let requiredValue = [F4STemplate(uuid: "uuid", template: "template", blanks: [])]
        let requiredResult = F4SNetworkResult.success(requiredValue)
        let expectation  = XCTestExpectation(description: "")
        sut.networkTaskfactory = MockF4SNetworkTaskFactory(requiredSuccessResult:
            requiredResult)
        sut.getTemplates() { (result) in
            switch result {
            case .error(_):
                XCTFail("This test was designed to return a success result")
            case .success(let templates):
                expectation.fulfill()
                XCTAssertEqual(templates.count,1)
            }
        }
        wait(for: [expectation], timeout: 1)
    }
}
