//
//  WorkfinderCommonTests.swift
//  WorkfinderCommonTests
//
//  Created by Keith Dev on 09/03/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import XCTest
@testable import WorkfinderCommon

class WorkfinderCommonTests: XCTestCase {

    func testWorkfinderCommon() {
        let greeting = WorkfinderCommon().sayHello(to: "you")
        XCTAssertEqual(greeting, "Hello you from WorkfinderCommon")
    }

}
