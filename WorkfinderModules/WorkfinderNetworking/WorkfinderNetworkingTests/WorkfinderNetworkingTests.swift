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
    
    override func setUp() {
        super.setUp()
        sharedSessionManager = nil
    }
    
    override func tearDown() {
        super.tearDown()
        sharedSessionManager = nil
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
    
    func test_WEXHTTPRequestVerb_names() {
        let data = Data()
        XCTAssertEqual(WEXHTTPRequestVerb.delete.name, "DELETE")
        XCTAssertEqual(WEXHTTPRequestVerb.get.name, "GET")
        XCTAssertEqual(WEXHTTPRequestVerb.patch(data).name, "PATCH")
        XCTAssertEqual(WEXHTTPRequestVerb.post(data).name, "POST")
        XCTAssertEqual(WEXHTTPRequestVerb.put(data).name, "PUT")
    }
    
}
