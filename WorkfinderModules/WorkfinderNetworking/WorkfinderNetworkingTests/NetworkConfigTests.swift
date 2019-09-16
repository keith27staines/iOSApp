//
//  NetworkConfigTests.swift
//  WorkfinderNetworkingTests
//
//  Created by Keith Dev on 17/07/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import XCTest
import WorkfinderCommon
import WorkfinderNetworking

class NetworkConfigTests: XCTestCase {

    func test_configure() {
        let log = MockLog()
        let config = NetworkConfig(workfinderApiKey: "someKey", workfinderBaseApi: "someUrl", log: log)
        XCTAssertEqual(config.wexApiKey, "someKey")
        XCTAssertEqual(config.workfinderApi, "someUrl")
        XCTAssertEqual(config.workfinderApiV2, "someUrl/v2")
        XCTAssertEqual(config.endpoints.base, "someUrl")
        XCTAssertEqual(config.endpoints.baseUrl2, "someUrl/v2")
    }
}

