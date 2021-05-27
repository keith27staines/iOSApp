//
//  NullEncodableTests.swift
//  WorkfinderCommonTests
//
//  Created by Keith Staines on 27/05/2021.
//  Copyright © 2021 Workfinder. All rights reserved.
//

import XCTest
import WorkfinderCommon

class NullEncodableTests: XCTestCase {

    func test_nullEncoding() throws {
        var test = Test()
        test.tuplet = Tuplet(a: "tuplet_a", b: 42)
        test.description = "test_description"

        let data = try JSONEncoder().encode(test)
        let string = String(data: data, encoding: .utf8) ?? ""
        XCTAssertTrue(string.contains("\"c\":null"))
    }
    
    struct Tuplet: Encodable {
        let a: String
        let b: Int
        @NullEncodable var c: String? = nil
    }

    struct Test: Encodable {
        @NullEncodable var name: String? = nil
        @NullEncodable var description: String? = nil
        @NullEncodable var tuplet: Tuplet? = nil
    }

}
