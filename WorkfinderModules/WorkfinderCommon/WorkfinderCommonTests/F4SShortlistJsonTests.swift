//
//  F4SShortlistJsonTests.swift
//  WorkfinderCommonTests
//
//  Created by Keith Dev on 05/02/2020.
//  Copyright © 2020 Founders4Schools. All rights reserved.
//

import XCTest
@testable import WorkfinderCommon

class F4SShortlistJsonTests: XCTestCase {

    func test_initialise() {
        let errors = F4SServerErrors(errors: F4SJSONValue(integerLiteral: 1))
        let sut = F4SShortlistJson(uuid: "shortlistUuid", companyUuid: "companyUuid", errors: errors)
        
        XCTAssertEqual(sut.uuid, "shortlistUuid")
        XCTAssertEqual(sut.companyUuid, "companyUuid")
        XCTAssertNotNil(sut.errors?.errors)
    }
    

}
