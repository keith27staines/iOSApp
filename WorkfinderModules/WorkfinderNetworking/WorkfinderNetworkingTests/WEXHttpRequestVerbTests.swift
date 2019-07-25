//
//  WEXHttpRequestVerbTests.swift
//  WorkfinderNetworkingTests
//
//  Created by Keith Dev on 24/07/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import XCTest
@testable import WorkfinderNetworking

class WEXHttpRequestVerbTests: XCTestCase {
    
    func test_names() {
        XCTAssertEqual(WEXHTTPRequestVerb.delete.name, "DELETE")
        XCTAssertEqual(WEXHTTPRequestVerb.get.name, "GET")
        XCTAssertEqual(WEXHTTPRequestVerb.patch(Data()).name, "PATCH")
        XCTAssertEqual(WEXHTTPRequestVerb.post(Data()).name, "POST")
        XCTAssertEqual(WEXHTTPRequestVerb.put(Data()).name, "PUT")
    }
}
