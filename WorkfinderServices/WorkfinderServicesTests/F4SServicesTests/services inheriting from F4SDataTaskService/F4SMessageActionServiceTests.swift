import XCTest
import WorkfinderCommon
@testable import WorkfinderServices

class F4SMessageActionServiceTests: XCTestCase {

    func test_initialise() {
        let threadUuid = "threadUuid"
        let sut = F4SMessageActionService(threadUuid: threadUuid, configuration: makeTestConfiguration())
        XCTAssertEqual(sut.apiName, "messaging/\(threadUuid)/user_action")
    }
    
    func test_getMessageAction() {
        let threadUuid = "threadUuid"
        let actionType = F4SActionType.viewOffer
        let sut = F4SMessageActionService(threadUuid: threadUuid, configuration: makeTestConfiguration())
        let action = makeAction(type: actionType)
        let requiredResult = F4SNetworkResult.success(action)
        sut.networkTaskfactory = MockF4SNetworkTaskFactory(requiredSuccessResult: requiredResult)
        let expectation = XCTestExpectation(description: "")
        sut.getMessageAction { (result) in
            switch result {
            case .error(_):
                XCTFail("The test was designed to return a success result")
            case .success(let action):
                XCTAssertEqual(action?.actionType, actionType)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func makeAction(type: F4SActionType) -> F4SAction {
        let actionType = F4SActionType.viewOffer
        let argument = F4SActionArgument(name: F4SActionArgumentName.placementUuid, value: ["placementUuid"])
        return F4SAction(originatingMessageUuid: "originatingMessageUuid", actionType: actionType, arguments: [argument])
    }

}
