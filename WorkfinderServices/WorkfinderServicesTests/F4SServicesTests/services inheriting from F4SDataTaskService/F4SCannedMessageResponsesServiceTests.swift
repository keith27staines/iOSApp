import XCTest
import WorkfinderCommon
import WorkfinderNetworking
@testable import WorkfinderServices

class F4SCannedMessageResponsesServiceTests: XCTestCase {
    
    func test_initialise() {
        let threadUuid = "threadUuid"
        let sut = F4SCannedMessageResponsesService(threadUuid: threadUuid)
        XCTAssertEqual(sut.apiName, "messaging/\(threadUuid)/possible_responses")
    }
    
    func test_getPermittedResponses() {
        let threadUuid = "threadUuid"
        let sut = F4SCannedMessageResponsesService(threadUuid: threadUuid)
        let responses = F4SCannedResponses(uuid: "responsesUuid", responses: [F4SCannedResponse(uuid: "responseUuid", value: "responseValue")])
        let requiredResult = F4SNetworkResult.success(responses)
        sut.networkTaskfactory = MockF4SNetworkTaskFactory(requiredSuccessResult: requiredResult)
        let expectation = XCTestExpectation(description: "")
        sut.getPermittedResponses() { (result) in
            switch result {
            case .error(_):
                XCTFail("The test was designed to return a success result")
            case .success(let responses):
                XCTAssertEqual(responses.uuid, "responsesUuid")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }


}
