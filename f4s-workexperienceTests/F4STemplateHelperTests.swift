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
        let unavailableChoice1 = Choice(uuid: "unavailableChoice1", value: "unavailableChoice1")
        let unavailableChoice2 = Choice(uuid: "unavailableChoice2", value: "unavailableChoice2")
        let availablechoice1 = Choice(uuid: "availablechoice1", value: "availablechoice1")
        let allowedChoices : [Choice] = [availablechoice1]
        let templateBlank = TemplateBlank(name: "field 1", placeholder: "Field 1", optionType: .multiSelect, maxChoice: 3, choices: allowedChoices, initial: "placeholder")
        let currentChoices : [Choice] = [unavailableChoice1, unavailableChoice2, availablechoice1]
        let blank = TemplateBlank(name: "field 1", placeholder: "Field 1", optionType: .multiSelect, maxChoice: 3, choices: currentChoices, initial: "placeholder")
        let prunedBlank = TemplateHelper.removeUnavailableChoices(from: blank, templateBlank: templateBlank)
        XCTAssertTrue(prunedBlank.choices.count == 1)
        XCTAssertTrue(prunedBlank.choices.first?.uuid == availablechoice1.uuid)
    }
    
    func test_RemoveUnavailableChoicesFromBlank_IsADate() {
        let dateChoice1 = Choice(uuid: "2018-02-09T00:00:00Z", value: "2018-02-09T00:00:00Z")
        let allowedChoices : [Choice] = []
        let templateBlank = TemplateBlank(name: "field 1", placeholder: "Field 1", optionType: .multiSelect, maxChoice: 3, choices: allowedChoices, initial: "placeholder")
        let currentChoices : [Choice] = [dateChoice1]
        let blank = TemplateBlank(name: "field 1", placeholder: "Field 1", optionType: .multiSelect, maxChoice: 3, choices: currentChoices, initial: "placeholder")
        let prunedBlank = TemplateHelper.removeUnavailableChoices(from: blank, templateBlank: templateBlank)
        XCTAssertTrue(prunedBlank.choices.count == 1)
        XCTAssertTrue(prunedBlank.choices.first?.uuid == dateChoice1.uuid)
    }
}
