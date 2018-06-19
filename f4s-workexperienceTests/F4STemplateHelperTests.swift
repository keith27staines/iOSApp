//
//  F4STemplateHelperTests.swift
//  f4s-workexperienceTests
//
//  Created by Keith Dev on 08/02/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import XCTest
@testable import f4s_workexperience

class F4STemplateHelperTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_RemoveUnavailableChoicesFromBlank_NotADate() {
        let unavailableChoice1 = F4SChoice(uuid: "unavailableChoice1", value: "unavailableChoice1")
        let unavailableChoice2 = F4SChoice(uuid: "unavailableChoice2", value: "unavailableChoice2")
        let availablechoice1 = F4SChoice(uuid: "availablechoice1", value: "availablechoice1")
        let allowedChoices : [F4SChoice] = [availablechoice1]
        let templateBlank = F4STemplateBlank(name: "field 1", placeholder: "Field 1", optionType: .multiselect, maxChoices: 3, choices: allowedChoices, initial: "placeholder")
        let currentChoices : [F4SChoice] = [unavailableChoice1, unavailableChoice2, availablechoice1]
        let blank = F4STemplateBlank(name: "field 1", placeholder: "Field 1", optionType: .multiselect, maxChoices: 3, choices: currentChoices, initial: "placeholder")
        let prunedBlank = TemplateHelper.removeUnavailableChoices(from: blank, templateBlank: templateBlank)
        XCTAssertTrue(prunedBlank.choices.count == 1)
        XCTAssertTrue(prunedBlank.choices.first?.uuid == availablechoice1.uuid)
    }
    
    func test_RemoveUnavailableChoicesFromBlank_IsADate() {
        let dateChoice1 = F4SChoice(uuid: "2018-02-09T00:00:00Z", value: "2018-02-09T00:00:00Z")
        let allowedChoices : [F4SChoice] = []
        let templateBlank = F4STemplateBlank(name: "field 1", placeholder: "Field 1", optionType: .multiselect, maxChoices: 3, choices: allowedChoices, initial: "placeholder")
        let currentChoices : [F4SChoice] = [dateChoice1]
        let blank = F4STemplateBlank(name: "field 1", placeholder: "Field 1", optionType: .multiselect, maxChoices: 3, choices: currentChoices, initial: "placeholder")
        let prunedBlank = TemplateHelper.removeUnavailableChoices(from: blank, templateBlank: templateBlank)
        XCTAssertTrue(prunedBlank.choices.count == 1)
        XCTAssertTrue(prunedBlank.choices.first?.uuid == dateChoice1.uuid)
    }
}
