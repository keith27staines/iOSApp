import XCTest
import WorkfinderCommon
@testable import WorkfinderServices

class F4SContentServiceTests: XCTestCase {

    func test_initialise() {
        let sut = F4SContentService(configuration: makeTestConfiguration())
        XCTAssertEqual(sut.apiName, "content")
    }
    
    func test_getContent() {
        let sut = F4SContentService(configuration: makeTestConfiguration())
        let descriptor = [F4SContentDescriptor(title: "title", slug: F4SContentType.company)]
        let requiredResult = F4SNetworkResult.success(descriptor)
        sut.networkTaskfactory = MockF4SNetworkTaskFactory(requiredSuccessResult: requiredResult)
        let expectation = XCTestExpectation(description: "")
        sut.getContent() { (result) in
            switch result {
            case .error(_):
                XCTFail("The test was designed to return a success result")
            case .success(let content):
                XCTAssertEqual(content.first!.slug, F4SContentType.company)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
}
