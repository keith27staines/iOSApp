//
//  NetworkConfigTests.swift
//  WorkfinderNetworkingTests
//
//  Created by Keith Dev on 17/07/2019.
//  Copyright © 2019 Workfinder Ltd. All rights reserved.
//

import XCTest
import WorkfinderCommon
import WorkfinderNetworking

class NetworkConfigTests: XCTestCase {

    func test_configure() {
        let logger = NetworkCallLogger(log: MockF4SAnalyticsAndDebugging())
        let endpoints = try! WorkfinderEndpoint(baseUrlString: "someUrl")
        let sessionManager = F4SNetworkSessionManager(appVersion: "")
        let user = User()
        let userRepo = MockUserRepository(user: user)
        let config = NetworkConfig(logger: logger,
                                   sessionManager: sessionManager,
                                   workfinderEndpoint: endpoints,
                                   userRepository: userRepo)
        XCTAssertEqual(config.workfinderApiV3, "someUrl")
        XCTAssertEqual(config.workfinderApiEndpoint.workfinderApiUrlString, "someUrl")
    }
}

