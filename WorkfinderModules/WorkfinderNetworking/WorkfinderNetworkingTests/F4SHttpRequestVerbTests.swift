//
//  F4SHttpRequestVerbTests.swift
//  WorkfinderNetworkingTests
//
//  Created by Keith Dev on 17/07/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import XCTest
@testable import WorkfinderNetworking

class F4SHttpRequestVerbTests: XCTestCase {

    func test_names() {
        XCTAssertEqual(F4SHttpRequestVerb.delete.name, "DELETE")
        XCTAssertEqual(F4SHttpRequestVerb.get.name, "GET")
        XCTAssertEqual(F4SHttpRequestVerb.patch.name, "PATCH")
        XCTAssertEqual(F4SHttpRequestVerb.post.name, "POST")
        XCTAssertEqual(F4SHttpRequestVerb.put.name, "PUT")
    }
}
