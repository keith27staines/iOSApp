//
//  ScaledNumberTests.swift
//  F4SPrototypesTests
//
//  Created by Keith Dev on 26/01/2019.
//  Copyright © 2019 Keith Staines. All rights reserved.
//

import XCTest
@testable import WorkfinderCommon

class ScaledNumberTests : XCTestCase {
    
    func testFormattedString_With999_999() {
        let amount = 999999.0
        let sut = ScaledNumber(amount: amount)
        XCTAssertEqual(sut.formattedString(),"1.0m")
    }
    
    func testFormattedString_With100_000() {
        let amount = 100_000.0
        let sut = ScaledNumber(amount: amount)
        XCTAssertEqual(sut.formattedString(),"100.0k")
    }
    
    func testFormattedString_With99_951() {
        let amount = 99_951.0
        let sut = ScaledNumber(amount: amount)
        XCTAssertEqual(sut.formattedString(),"100.0k")
    }
    
    func testFormattedString_With90_949() {
        let amount = 99_949.0
        let sut = ScaledNumber(amount: amount)
        XCTAssertEqual(sut.formattedString(),"99.9k")
    }
    
    func testFormattedString_With999() {
        let amount = 999.0
        let sut = ScaledNumber(amount: amount)
        XCTAssertEqual(sut.formattedString(),"999")
    }
    
    func testFormattedString_With1001() {
        let amount = 1001.0
        let sut = ScaledNumber(amount: amount)
        XCTAssertEqual(sut.formattedString(),"1.0k")
    }
    
    func testFormattedString_With1949() {
        let amount = 1949.0
        let sut = ScaledNumber(amount: amount)
        XCTAssertEqual(sut.formattedString(),"1.9k")
    }
    
    func testFormattedString_With1951() {
        let amount = 1951.0
        let sut = ScaledNumber(amount: amount)
        XCTAssertEqual(sut.formattedString(),"2.0k")
    }
    
    func testFormattedString_With1000_000() {
        let amount = 1_000_000.0
        let sut = ScaledNumber(amount: amount)
        XCTAssertEqual(sut.formattedString(),"1.0m")
    }
    
    func testFormattedString_With1000_000_000() {
        let amount = 1_000_000_000.0
        let sut = ScaledNumber(amount: amount)
        XCTAssertEqual(sut.formattedString(),"1.0b")
    }
    
    func testFormattedString_With1000_000_000_000() {
        let amount = 1_000_000_000_000.0
        let sut = ScaledNumber(amount: amount)
        XCTAssertEqual(sut.formattedString(),"1.0t")
    }
    
    func testMoneyScale_WithBase() {
        let amount = 100.0
        let sut = ScaledNumber(amount: amount)
        XCTAssertEqual(sut.scale, .base)
        XCTAssertEqual(sut.symbol, "")
    }
    
    func testScaledNumber_WithThousand() {
        let amount = 1000.0
        let sut = ScaledNumber(amount: amount)
        XCTAssertEqual(sut.scale, ScaledNumber.Scale.thousand)
        XCTAssertEqual(sut.symbol, "k")
    }
    
    func testScaledNumber_WithMillion() {
        let amount = 1_000_000.0
        let sut = ScaledNumber(amount: amount)
        XCTAssertEqual(sut.scale, ScaledNumber.Scale.million)
        XCTAssertEqual(sut.symbol, "m")
    }
    
    func testScaledNumber_WithBillion() {
        let amount = 1000_000_000.0
        let sut = ScaledNumber(amount: amount)
        XCTAssertEqual(sut.scale, ScaledNumber.Scale.billion)
        XCTAssertEqual(sut.symbol, "b")
    }
    
    func testScaledNumber_WithTrillion() {
        let amount = 1000_000_000_000.0
        let sut = ScaledNumber(amount: amount)
        XCTAssertEqual(sut.scale, ScaledNumber.Scale.trillion)
        XCTAssertEqual(sut.symbol, "t")
    }
    
    func testFormattedStringStatic() {
        let amount = 1951.0
        XCTAssertEqual(ScaledNumber.formattedString(for: amount),"2.0k")
    }
}
