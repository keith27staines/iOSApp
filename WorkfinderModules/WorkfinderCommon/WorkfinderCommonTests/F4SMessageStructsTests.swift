//
//  F4SMessageStructsTests.swift
//  WorkfinderCommonTests
//
//  Created by Keith Dev on 23/08/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import XCTest
@testable import WorkfinderCommon

class F4SMessagesListTests: XCTestCase {

    func test_initialise() {
        let sut = F4SMessagesList()
        XCTAssertEqual(sut.count, 0)
        XCTAssertEqual(sut.messages.count, 0)
    }
}

class F4SCannedResponsesTests: XCTestCase {
    
    func test_initialise() {
        let sut = F4SCannedResponses(uuid: "uuid", responses: [])
        XCTAssertEqual(sut.uuid, "uuid")
        XCTAssertEqual(sut.options.count, 0)
    }
}

class F4SCannedResponseTests: XCTestCase {
    
    func test_initialise() {
        let sut = F4SCannedResponse(uuid: "uuid", value: "value")
        XCTAssertEqual(sut.uuid, "uuid")
        XCTAssertEqual(sut.value, "value")
    }
}

class F4SActionTests : XCTestCase {
    func test_initialise() {
        let sut = F4SAction(originatingMessageUuid: "originatingMessage",
                            actionType: F4SActionType.uploadDocuments,
                            arguments: [F4SActionArgument(
                                name: F4SActionArgumentName.documentType,
                                value: ["value"])])
        XCTAssertEqual(sut.originatingMessageUuid, "originatingMessage")
        XCTAssertEqual(sut.actionType, F4SActionType.uploadDocuments)
        XCTAssertEqual(sut.arguments?.count, 1)
        XCTAssertEqual(sut.arguments?.first?.argumentName, F4SActionArgumentName.documentType)
    }
    
    func test_argument_when_arguments_exist() {
        let arg1 = F4SActionArgument(name: F4SActionArgumentName.documentType, value: ["value1"])
        let arg2 = F4SActionArgument(name: F4SActionArgumentName.placementUuid, value: ["value2"])
        let arg3 = F4SActionArgument(name: F4SActionArgumentName.externalWebsite, value: ["value3"])
        let sut = F4SAction(originatingMessageUuid: "originatingMessage",
                            actionType: F4SActionType.uploadDocuments,
                            arguments: [arg1, arg2, arg3])
        let arg = sut.argument(name: F4SActionArgumentName.placementUuid)
        XCTAssertEqual(arg?.argumentName, F4SActionArgumentName.placementUuid)
    }
    
    func test_argument_when_no_arguments_exist() {
        let sut = F4SAction(originatingMessageUuid: "originatingMessage",
                            actionType: F4SActionType.uploadDocuments,
                            arguments: nil)
        XCTAssertNil(sut.argument(name: F4SActionArgumentName.documentType))
    }
}

class F4SActionTypeTests : XCTestCase {
    func test_actionTitle() {
        XCTAssertEqual(F4SActionType.uploadDocuments.actionTitle, "Add documents")
        XCTAssertEqual(F4SActionType.viewOffer.actionTitle, "View offer")
        XCTAssertEqual(F4SActionType.viewCompanyExternalApplication.actionTitle, "Apply externally")
    }
}

class F4SActionArgumentTests : XCTestCase {

    func test_intialise() {
        let sut = F4SActionArgument(name: F4SActionArgumentName.documentType, value: ["value"])
        XCTAssertEqual(sut.argumentName, F4SActionArgumentName.documentType)
        XCTAssertEqual(sut.value, ["value"])
    }
}
