//
//  F4SGrammarTests.swift
//  f4s-workexperienceTests
//
//  Created by Keith Dev on 05/02/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import XCTest
@testable import f4s_workexperience

class F4SGrammarTests: XCTestCase {
    
    func testEmptyGrammaticalList() {
        let items = [String]()
        let string = F4SGrammar.list(items)
        XCTAssertNil(string)
    }
    
    func testGrammaticalList_1_Entry() {
        let items = ["Item 1"]
        let string = F4SGrammar.list(items)
        XCTAssertEqual(string, "Item 1")
    }
    
    func testGrammaticalList_2_Entries() {
        let items = ["Item 1", "Item 2"]
        let string = F4SGrammar.list(items)
        XCTAssertEqual(string, "Item 1 and Item 2")
    }
    
    func testGrammaticalList_3_Entries() {
        let items = ["Item 1", "Item 2", "Item 3"]
        let string = F4SGrammar.list(items)
        XCTAssertEqual(string, "Item 1, Item 2, and Item 3")
    }
    
    func testGrammaticalList_4_Entries() {
        let items = ["Item 1", "Item 2", "Item 3", "Item 4"]
        let string = F4SGrammar.list(items)
        XCTAssertEqual(string, "Item 1, Item 2, Item 3, and Item 4")
    }
}
