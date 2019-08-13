//
//  F4SAnonymousUserTests.swift
//  WorkfinderCommonTests
//
//  Created by Keith Dev on 09/08/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import XCTest
import WorkfinderCommon

class F4SAnonymousUserTests: XCTestCase {

    func test_initialise() {
        let sut = F4SAnonymousUser(vendorUuid: "vendor uuid", clientType: "client type", apnsEnvironment: "test environment")
        XCTAssertEqual(sut.apnsEnvironment, "test environment")
        XCTAssertEqual(sut.clientType, "client type")
        XCTAssertEqual(sut.vendorUuid, "vendor uuid")
    }
    
    func test_decode() {
        let jsonString = """
        {
            \"vendor_uuid\":\"vendor uuid\",
            \"type\":\"client type\",
            \"env\":\"test environment\"
        }
        """
        let data = jsonString.data(using: String.Encoding.utf8)!
        let sut = try! JSONDecoder().decode(F4SAnonymousUser.self, from: data)
        XCTAssertEqual(sut.vendorUuid, "vendor uuid")
    }

}
