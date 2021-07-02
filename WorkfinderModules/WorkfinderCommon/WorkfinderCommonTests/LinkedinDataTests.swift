//
//  LinkedinDataTests.swift
//  WorkfinderCommonTests
//
//  Created by Keith on 01/07/2021.
//  Copyright © 2021 Workfinder. All rights reserved.
//

import Foundation

import XCTest
import WorkfinderCommon

class LinkedinDataTests: XCTestCase {
    
    func test_string() throws {
        let json = _linkedinJsonString
        let data = json.data(using: .utf8)!
        let connections = try JSONDecoder().decode([SocialConnection].self, from: data)
        XCTAssertEqual(connections.count,1)
        print(connections[0])
    }
}

