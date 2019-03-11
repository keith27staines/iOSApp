//
//  WorkfinderUITests.swift
//  WorkfinderUITests
//
//  Created by Keith Dev on 09/03/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import XCTest
@testable import WorkfinderUI

class WorkfinderUITests: XCTestCase {

    func testWorkfinderUI() {
        let greeting = WorkfinderUI().sayHello(to: "you")
        XCTAssertEqual(greeting, "Hello you from WorkfinderUI")
    }

}
