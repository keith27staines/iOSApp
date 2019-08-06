//
//  F4STemplateTests.swift
//  WorkfinderCommonTests
//
//  Created by Keith Dev on 06/08/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import XCTest
@testable import WorkfinderCommon

class F4STemplateTests: XCTestCase {

    func test_template_nitialise() {
        let sut = F4STemplate(uuid: "uuid", template: "template", blanks: [])
        XCTAssertEqual(sut.uuid, "uuid")
    }
    
}

class F4STemplateBlankTests: XCTestCase {
    func test_templateBlank_initialise() {
//        let sut = F4STemplateBlank(name: "name", placeholder: "placeholder", optionType: F4STemplateOptionType.select, maxChoices: 3, choices: <#T##[F4SChoice]#>, initial: <#T##String?#>)
    }
}
