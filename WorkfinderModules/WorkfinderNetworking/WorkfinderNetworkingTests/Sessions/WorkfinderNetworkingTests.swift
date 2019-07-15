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
    
    func testSharedInstanceIsNilBeforeCallingCreate() {
        XCTAssertNil(sharedSessionManager)
    }
    
    func testSharedInstanceNotNilAfterConfigure() {
        let config = makeMockNetworkConfiguration()
        XCTAssertNil(sharedSessionManager)
        try! configureWEXSessionManager(configuration: config)
        XCTAssertNotNil(sharedSessionManager)
    }
    
    func testConfigureThrowsIfCalledTwice() {
        let config = makeMockNetworkConfiguration()
        try! configureWEXSessionManager(configuration: config)
        XCTAssertThrowsError(try configureWEXSessionManager(configuration: config))
    }
    
}
