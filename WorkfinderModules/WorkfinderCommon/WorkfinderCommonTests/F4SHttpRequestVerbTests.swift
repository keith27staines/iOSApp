//
//  F4SHttpRequestVerbTests.swift
//  WorkfinderCommonTests
//
//  Created by Keith Dev on 03/02/2020.
//  Copyright © 2020 Founders4Schools. All rights reserved.
//

import XCTest
@testable import WorkfinderCommon

class F4SHttpRequestVerbTests: XCTestCase {

    func test_init_with_name() {
        XCTAssertEqual(F4SHttpRequestVerb(verbName: "GET")?.name, "GET")
        XCTAssertEqual(F4SHttpRequestVerb(verbName: "PUT")?.name, "PUT")
        XCTAssertEqual(F4SHttpRequestVerb(verbName: "PATCH")?.name, "PATCH")
        XCTAssertEqual(F4SHttpRequestVerb(verbName: "POST")?.name, "POST")
        XCTAssertEqual(F4SHttpRequestVerb(verbName: "DELETE")?.name, "DELETE")
    }

}
