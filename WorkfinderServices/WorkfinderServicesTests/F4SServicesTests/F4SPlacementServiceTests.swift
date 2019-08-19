//
//  F4SPlacementServiceTests.swift
//  WorkfinderServicesTests
//
//  Created by Keith Dev on 19/08/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import XCTest
import WorkfinderNetworking
@testable import WorkfinderServices

class F4SPlacementServiceTests: XCTestCase {

    func test_initialise() {
        let sessionManager = MockF4SNetworkSessionManager()
        let sut = F4SPlacementService(sessionManager: sessionManager)
        XCTAssertTrue(sut.sessionManager as! MockF4SNetworkSessionManager === sessionManager)
    }

}

class MockF4SDataTaskRequestFactory {
    
}

class MockF4SNetworkSessionManager: F4SNetworkSessionManagerProtocol {
    
    var interactiveSession: URLSession {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }
    
    
}
