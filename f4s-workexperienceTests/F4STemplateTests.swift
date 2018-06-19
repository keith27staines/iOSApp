//
//  F4STemplateTests.swift
//  f4s-workexperienceTests
//
//  Created by Keith Dev on 08/02/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import XCTest
@testable import f4s_workexperience

class F4STemplateTests: XCTestCase {
    
    func test_Choice_uuidNotDate() {
        let choice = F4SChoice(uuid: "abc", value: "fhkds")
        XCTAssertFalse(choice.uuidIsDate)
    }
    
    func test_Choice_uuidIsDate() {
        let choice = F4SChoice(uuid: "2018-02-09T00:00:00Z", value: "fhkds")
        XCTAssertTrue(choice.uuidIsDate)
    }
    
}
