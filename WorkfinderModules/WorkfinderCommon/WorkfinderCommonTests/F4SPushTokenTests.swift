//
//  F4SPushTokenTests.swift
//  WorkfinderCommonTests
//
//  Created by Keith Dev on 09/08/2019.
//  Copyright © 2019 Workfinder Ltd. All rights reserved.
//

import XCTest
import WorkfinderCommon

class F4SPushTokenTests: XCTestCase {
    let pushTokenValue = "push token value"
    var pushTokenJsonString: String { return "{\"push_token\": \"\(pushTokenValue)}" }
    var pushTokenData: Data { return pushTokenJsonString.data(using: .utf8)! }

    func test_initialise() {
        let sut = F4SPushToken(pushToken: pushTokenValue)
        XCTAssertTrue(sut.pushToken == pushTokenValue)
    }
    
    func test_json_encode_decode() {
        let sut = F4SPushToken(pushToken: pushTokenValue)
        let data = try! JSONEncoder().encode(sut)
        let recovered = try! JSONDecoder().decode(F4SPushToken.self, from: data)
        XCTAssertEqual(recovered.pushToken, pushTokenValue)
    }

}
