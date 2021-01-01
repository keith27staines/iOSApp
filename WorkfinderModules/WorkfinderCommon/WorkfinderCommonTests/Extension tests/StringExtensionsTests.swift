//
//  StringExtensionsTests.swift
//  WorkfinderCommonTests
//
//  Created by Keith Dev on 07/08/2019.
//  Copyright © 2019 Workfinder Ltd. All rights reserved.
//

import XCTest
import WorkfinderCommon

class StringExtensionsTests: XCTestCase {

    func test_string_widthOfString_with_empty_string() {
        let string = ""
        let x = string.widthOfString(usingFont: UIFont.systemFont(ofSize: 17))
        XCTAssertTrue(x == 0.0)
    }
    
    func test_string_widthOfString_with_non_empty_string() {
        let string = "H"
        let x = string.widthOfString(usingFont: UIFont.systemFont(ofSize: 17))
        XCTAssertTrue(x > 10 && x < 14)
    }
    
    func test_string_heightOfString_with_empty_string() {
        let string = ""
        let x = string.heightOfString(usingFont: UIFont.systemFont(ofSize: 17))
        XCTAssertTrue(x > 18.0 && x < 22.0)
    }
    
    func test_string_heightOfString_with_non_empty_string() {
        let string = "H"
        let x = string.heightOfString(usingFont: UIFont.systemFont(ofSize: 17))
        XCTAssertTrue(x > 0.0)
    }
    
    func test_string_sizeOfString() {
        let string = "H"
        let size = string.sizeOfString(usingFont: UIFont.systemFont(ofSize: 17))
        XCTAssertTrue(size.height > 18.0 && size.height < 22.0)
        XCTAssertTrue(size.width > 10 && size.width < 14)
    }
    
    func test_stripCompanySuffix() {
        let company = "Some company"
        XCTAssertEqual((company + " limited").stripCompanySuffix(), company)
        XCTAssertEqual((company + " ltd").stripCompanySuffix(), company)
        XCTAssertEqual((company + " plc").stripCompanySuffix(), company)
        XCTAssertEqual((company + " ltd.").stripCompanySuffix(), company)
        XCTAssertEqual((company + " LIMITED").stripCompanySuffix(), company)
        XCTAssertEqual((company + " LTD").stripCompanySuffix(), company)
        XCTAssertEqual((company + " PLC").stripCompanySuffix(), company)
        XCTAssertEqual((company + " LTD.").stripCompanySuffix(), company)
    }
    
    func test_string_stringByReplacingFirstOccurrenceOfString() {
        XCTAssertEqual("first first first".stringByReplacingFirstOccurrenceOfString(target: "first", withString: "xxxx"), "xxxx first first")
        XCTAssertEqual("first first first".stringByReplacingFirstOccurrenceOfString(target: "aaaa", withString: "xxxx"), "first first first")
    }
    
    func test_index_returning_integer() {
        XCTAssertEqual("abcdef".index(of: "c", options: String.CompareOptions.literal)!, 2)
    }
    
    func test_index_returning_string_index() {
        let string = "abcdef"
        let indexOfC = string.firstIndex(of: "c")
        XCTAssertEqual(string.index(of: "c", options: String.CompareOptions.literal)!, indexOfC)
    }

}
