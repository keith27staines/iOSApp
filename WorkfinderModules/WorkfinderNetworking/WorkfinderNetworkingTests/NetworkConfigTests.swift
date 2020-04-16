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
        let logger = NetworkCallLogger(log: MockF4SAnalyticsAndDebugging())
        let endpoints = WorkfinderEndpoint(baseUrlString: "someUrl")
        let sessionManager = F4SNetworkSessionManager()
        let user = User()
        let userRepo = MockUserRepository(user: user)
        let config = NetworkConfig(logger: logger,
                                   sessionManager: sessionManager,
                                   endpoints: endpoints,
                                   userRepository: userRepo)
        XCTAssertEqual(config.workfinderApiV3, "someUrl")
        XCTAssertEqual(config.endpoints.workfinderApiUrlString, "someUrl")
    }
}

