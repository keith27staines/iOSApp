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
    
    var lastIdentity: F4SUUID? = nil
    
    func identity(userId: F4SUUID) { lastIdentity = userId}
    
    func alias(userId: F4SUUID) {}
    
    var notifiedErrors: [NSError] = []
    func notifyError(_ error: NSError, functionName: StaticString, fileName: StaticString, lineNumber: Int) {
        notifiedErrors.append(error)
    }
    
    var breadcrumbs: [String] = []
    func leaveBreadcrumb(with message: String, functionName: StaticString, fileName: StaticString, lineNumber: Int) {
        breadcrumbs.append(message)
    }
    
    func updateHistory() {}
    
    func textCombiningHistoryAndSessionLog() -> String? { return "" }
    
    func userCanAccessDebugMenu() -> Bool { return false }
    
    var errorText: [String] = []
    func error(message: String, functionName: StaticString, fileName: StaticString, lineNumber: Int) {
        errorText.append(message)
    }
    
    func error(_ error: Error, functionName: StaticString, fileName: StaticString, lineNumber: Int) {}
    
    var debugText: [String] = []
    func debug(_ message: String, functionName: StaticString, fileName: StaticString, lineNumber: Int) {
        debugText.append(message)
    }
    
}
