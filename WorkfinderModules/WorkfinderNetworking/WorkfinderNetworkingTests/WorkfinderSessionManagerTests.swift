//
//  WorkfinderSessionManagerTests.swift
//  WorkfinderNetworkingTests
//
//  Created by Keith Dev on 10/03/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import XCTest
import WorkfinderCommon
@testable import WorkfinderNetworking

class WEXSessionManagerTests : XCTestCase {
    
    func testInitWEXSessionManagerWithConfiguration() {
        let config = makeNetworkConfiguration()
        let sut = WEXSessionManager(configuration: config)
        assertEqual(config1: config, config2: sut.configuration)
    }
    
    func testFirstRegistrationHeaders() {
        let sut = makeSUT()
        XCTAssertEqual(sut.firstRegistrationHeaders, ["wex.api.key": sut.configuration.wexApiKey])
    }
    
    func testDefaultHeadersIsEmpty_whenNoUser() {
        let sut = makeSUT()
        XCTAssertEqual(sut.defaultHeaders, ["wex.api.key": sut.configuration.wexApiKey])
    }
    
    func testDefaultHeadersIsNotEmpty_whenUser() {
        let sut = makeSUT()
        sut.rebuildWexUserSession(user: "1234")
        XCTAssertEqual(sut.defaultHeaders[HeaderKeys.wexApiKey.rawValue], sut.configuration.wexApiKey)
        XCTAssertEqual(sut.defaultHeaders[HeaderKeys.wexUserUuid.rawValue], "1234")
    }
    
    func testInitFirstRegistrationSession() {
        let sut = makeSUT()
        XCTAssertEqual(sut.firstRegistrationHeaders, ["wex.api.key": sut.configuration.wexApiKey])
        XCTAssertEqual(sut.firstRegistrationSession.configuration.httpAdditionalHeaders!.count,1)
    }
    
    func testWexUserSession_beforeUserSet() {
        let sut = makeSUT()
        XCTAssertEqual(sut.wexUserSession.configuration.httpAdditionalHeaders!.count,1)
        XCTAssertNil(sut.defaultHeaders[HeaderKeys.wexUserUuid.rawValue])
    }
    
    func testWexUserSession_afterBuildWexUserSession() {
        let sut = makeSUT()
        sut.rebuildWexUserSession(user: "1234")
        XCTAssertEqual(sut.wexUserSession.configuration.httpAdditionalHeaders!.count,2)
        XCTAssertEqual(sut.defaultHeaders[HeaderKeys.wexUserUuid.rawValue], "1234")
        sut.rebuildWexUserSession(user: "54321")
        XCTAssertEqual(sut.defaultHeaders[HeaderKeys.wexUserUuid.rawValue], "54321")
    }
    
    func testBuildSmallImageTests() {
        let sut = makeSUT()
        let cache = sut.makeSmallImageCache()
        XCTAssertEqual(cache.memoryCapacity, 5 * 1024 * 1024)
        XCTAssertEqual(cache.diskCapacity, 10 * 5 * 1024 * 1024)
    }
    
    func testsmallImageConfiguration() {
        let sut = makeSUT()
        let configuration = sut.smallImageSession.configuration
        XCTAssertEqual(configuration.urlCache?.memoryCapacity , 5 * 1024 * 1024)
        XCTAssertEqual(configuration.urlCache?.diskCapacity, 10 * 5 * 1024 * 1024)
        XCTAssertTrue(configuration.allowsCellularAccess)
    }

}

extension WEXSessionManagerTests {
    
    func makeSUT() -> WEXSessionManager {
        return WEXSessionManager(configuration: makeNetworkConfiguration())
    }
    
    func assertEqual(config1: WEXNetworkingConfigurationProtocol, config2: WEXNetworkingConfigurationProtocol) {
        XCTAssertEqual(config1.wexApiKey, config2.wexApiKey)
        XCTAssertEqual(config1.baseUrlString, config2.baseUrlString)
        XCTAssertEqual(config1.v1ApiUrlString, config2.v1ApiUrlString)
        XCTAssertEqual(config1.v2ApiUrlString, config2.v2ApiUrlString)
    }
}
