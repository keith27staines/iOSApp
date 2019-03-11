//
//  WorkfinderNetworkingTests.swift
//  WorkfinderNetworkingTests
//
//  Created by Keith Dev on 09/03/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import XCTest
import WorkfinderCommon
@testable import WorkfinderNetworking

class WorkfinderNetworkingTests: XCTestCase {
    
    override func setUp() { super.tearDown() }
    
    override func tearDown() {
        super.setUp()
        sharedSessionManager = nil
    }

    func testWorkfinderNetworking() {
        let greeting = WorkfinderNetworking().sayHello(to: "you")
        XCTAssertEqual(greeting, "Hello you from WorkfinderNetworking")
    }
    
    func testSharedInstanceIsNilBeforeCallingCreate() {
        XCTAssertNil(sharedSessionManager)
    }
    
    func testSharedInstanceNotNilAfterConfigure() {
        let config = makeNetworkConfiguration()
        XCTAssertNil(sharedSessionManager)
        try! configure(configuration: config)
        XCTAssertNotNil(sharedSessionManager)
    }
    
    func testConfigureThrowsIfCalledTwice() {
        let config = makeNetworkConfiguration()
        try! configure(configuration: config)
        XCTAssertThrowsError(try configure(configuration: config))
    }
    
}
