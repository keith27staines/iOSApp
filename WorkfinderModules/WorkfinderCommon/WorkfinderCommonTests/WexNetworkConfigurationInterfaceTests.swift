//
//  WorkfinderNetworkConfigurationInterfaceTests.swift
//  WorkfinderCommonTests
//
//  Created by Keith Dev on 10/03/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import XCTest
import WorkfinderCommon

class WorkfinderNetworkConfigurationInterfaceTests: XCTestCase {

    func testInterfaceInit() {
        let sut: WEXNetworkingConfigurationProtocol
        sut = WEXNetworkingConfiguration(
            wexApiKey: "apiKey",
            baseUrlString: "baseUrlString",
            v2ApiUrlString: "v2UrlString")
        XCTAssertEqual(sut.wexApiKey, "apiKey")
        XCTAssertEqual(sut.baseUrlString, "baseUrlString")
        XCTAssertEqual(sut.v2ApiUrlString, "v2UrlString")
    }

}
