//
//  CompanyJsonTests.swift
//  WorkfinderCommonTests
//
//  Created by Keith Dev on 05/02/2020.
//  Copyright © 2020 Founders4Schools. All rights reserved.
//

import XCTest
@testable import WorkfinderCommon

class CompanyJsonTests: XCTestCase {
    
    func test_linkedinUrl_when_string_is_nil() {
        let sut = CompanyJson()
        XCTAssertNil(sut.linkedInUrlString)
    }
    
    func test_duedilUrl_when_string_is_nil() {
        let sut = CompanyJson()
        XCTAssertNil(sut.duedilUrlString)
    }
}
