//
//  F4SCoreNetworkingTests.swift
//  F4SCoreNetworkingTests
//
//  Created by Keith Dev on 06/03/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import XCTest
@testable import F4SCoreNetworking

class F4SCoreNetworkingTests: XCTestCase {

    func testExperiment() {
        let sut = Experiment()
        XCTAssert(sut.sayHello() == "hello")
    }

}
