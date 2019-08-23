import XCTest
import WorkfinderCommon
import WorkfinderNetworking
@testable import WorkfinderServices

class F4SMessageServiceTests: XCTestCase {

    func test_initialise() {
        let threadUuid = "threadUuid"
        let sut = F4SMessageService(threadUuid: threadUuid)
        XCTAssertEqual(sut.apiName, "messaging/\(threadUuid)")
    }
    
    func test_getMessages() {
        let threadUuid = "threadUuid"
        let sut = F4SMessageService(threadUuid: threadUuid)
        var messageList = F4SMessagesList()
        let date = Date()
        messageList.count = 1
        messageList.messages = [F4SMessage(uuid: "messageUuid", dateTime: date)]
        let requiredResult = F4SNetworkResult.success(messageList)
        sut.networkTaskfactory = MockF4SNetworkTaskFactory(requiredSuccessResult: requiredResult)
        let expectation = XCTestExpectation(description: "")
        sut.getMessages() { (result) in
            switch result {
            case .error(_):
                XCTFail("The test was designed to return a success result")
            case .success(let messageList):
                let message = messageList.messages.first!
                XCTAssertEqual(messageList.count, 1)
                XCTAssertEqual(message.uuid, "messageUuid")
                XCTAssertEqual(Int(message.dateTime!.timeIntervalSinceReferenceDate), Int(date.timeIntervalSinceReferenceDate))
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

}
