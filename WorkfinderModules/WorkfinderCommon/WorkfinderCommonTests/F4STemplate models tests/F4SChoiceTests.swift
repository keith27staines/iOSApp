//
//  F4SChoiceTests.swift
//  WorkfinderCommonTests
//
//  Created by Keith Dev on 06/08/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import XCTest
@testable import WorkfinderCommon

class F4SChoiceTests: XCTestCase {
    
    func test_choice_initialise() {
        let sut = F4SChoice(uuid: "choiceUuid", value: "choiceValue")
        XCTAssertTrue(sut.uuid == "choiceUuid")
        XCTAssertTrue(sut.value == "choiceValue")
    }
    
    func test_choice_uuid_is_date_when_not_date() {
        let sut = F4SChoice(uuid: "choiceUuid", value: "")
        XCTAssertFalse(sut.uuidIsDate)
    }
    
    func test_choice_is_date_when_uuid_is_date() {
        let sut = F4SChoice(uuid: "2019-07-20", value: "")
        XCTAssertTrue(sut.uuidIsDate)
    }
}
