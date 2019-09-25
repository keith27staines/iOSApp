//
//  F4SJsonValueTests.swift
//  WorkfinderCommonTests
//
//  Created by Keith Dev on 08/08/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import XCTest
@testable import WorkfinderCommon

class F4SJsonValueTests: XCTestCase {
    func test_decode_with_string_array() {
        let data = "[\"hello\"]".data(using: .utf8)!
        let decoder = JSONDecoder()
        XCTAssertNoThrow(try decoder.decode(F4SJSONValue.self, from: data))
    }
    
    func test_init_with_literals() {
        let a = F4SJSONValue(stringLiteral: "hello")
        let b = F4SJSONValue(integerLiteral: 6)
        let c = F4SJSONValue(floatLiteral: 0.7)
        let d = F4SJSONValue(booleanLiteral: true)
        let e = F4SJSONValue(arrayLiteral: a,b,c,d)
        let f = F4SJSONValue(dictionaryLiteral: ("a", a), ("b", b), ("c", c), ("d", d), ("e", e))
        let encoder = JSONEncoder()
        let encodedData = try! encoder.encode(f)
        XCTAssertNoThrow(try JSONDecoder().decode(F4SJSONValue.self, from: encodedData))
    }
}
