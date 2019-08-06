//
//  F4SUUIDDictionarytests.swift
//  WorkfinderCommonTests
//
//  Created by Keith Dev on 06/08/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import XCTest
import WorkfinderCommon

class F4SUUIDDictionarytests: XCTestCase {

    func test_initialise() {
        let sut = F4SUUIDDictionary(uuid: "12345")
        XCTAssertTrue(sut.uuid == "12345")
    }
}
