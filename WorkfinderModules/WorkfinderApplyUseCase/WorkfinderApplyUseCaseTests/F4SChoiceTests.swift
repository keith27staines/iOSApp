//
//  F4SChoiceTests.swift
//  f4s-workexperienceTests
//
//  Created by Keith Dev on 08/02/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import XCTest
import WorkfinderCommon
@testable import WorkfinderApplyUseCase

class F4SChoiceTests: XCTestCase {
    
    func test_Choice_uuidNotDate() {
        let choice = F4SChoice(uuid: "abc", value: "fhkds")
        XCTAssertFalse(choice.uuidIsDate)
    }
    
    func test_Choice_uuidIsDate() {
        let choice = F4SChoice(uuid: "2018-02-09T00:00:00Z", value: "fhkds")
        XCTAssertTrue(choice.uuidIsDate)
    }
    
}
