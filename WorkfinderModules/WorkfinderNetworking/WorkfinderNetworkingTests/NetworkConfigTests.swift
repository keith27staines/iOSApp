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
        WorkfinderNetworking.configure(wexApiKey: "wexApi1234", workfinderBaseApi: "baseApi1234", log: log)
        XCTAssertEqual(NetworkConfig.wexApiKey, "wexApi1234")
        XCTAssertEqual(NetworkConfig.workfinderApi, "baseApi1234")
        XCTAssertEqual(NetworkConfig.workfinderApiV2, "baseApi1234/v2")
        XCTAssertNotNil(F4SNetworkSessionManager.shared)
    }
}

