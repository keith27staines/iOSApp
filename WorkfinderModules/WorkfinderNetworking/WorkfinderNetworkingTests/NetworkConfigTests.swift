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
        NetworkConfig.configure(wexApiKey: "wexApi1234", workfinderBaseApi: "baseApi1234", log: log)
        XCTAssertEqual(NetworkConfig.wexApiKey, "wexApi1234")
        XCTAssertEqual(NetworkConfig.workfinderApi, "baseApi1234")
        XCTAssertEqual(NetworkConfig.workfinderApiV2, "baseApi1234/v2")
        XCTAssertNotNil(F4SNetworkSessionManager.shared)
    }
}


class MockLog: F4SAnalyticsAndDebugging {
    func identity(userId: F4SUUID) {}
    
    func alias(userId: F4SUUID) {}
    
    func notifyError(_ error: NSError, functionName: StaticString, fileName: StaticString, lineNumber: Int) {}
    
    func leaveBreadcrumb(with message: String, functionName: StaticString, fileName: StaticString, lineNumber: Int) {}
    
    func updateHistory() {}
    
    func textCombiningHistoryAndSessionLog() -> String? { return "" }
    
    func userCanAccessDebugMenu() -> Bool { return false }
    
    func error(message: String, functionName: StaticString, fileName: StaticString, lineNumber: Int) {}
    
    func error(_ error: Error, functionName: StaticString, fileName: StaticString, lineNumber: Int) {}
    
    func debug(_ message: String, functionName: StaticString, fileName: StaticString, lineNumber: Int) {}
    
}
