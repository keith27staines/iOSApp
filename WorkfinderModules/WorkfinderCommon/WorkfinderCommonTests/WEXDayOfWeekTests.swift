//
//  WEXDayOfWeekTests.swift
//  WorkfinderCommonTests
//
//  Created by Keith Dev on 12/08/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import XCTest
@testable import WorkfinderCommon

class WEXDayOfWeekTests : XCTestCase {
    func test_initialise_from_zero_based_number() {
        XCTAssertTrue(WEXDayOfWeek(zeroBasedDayNumber: 0) == WEXDayOfWeek.monday)
        XCTAssertTrue(WEXDayOfWeek(zeroBasedDayNumber: 1) == WEXDayOfWeek.tuesday)
        XCTAssertTrue(WEXDayOfWeek(zeroBasedDayNumber: 2) == WEXDayOfWeek.wednesday)
        XCTAssertTrue(WEXDayOfWeek(zeroBasedDayNumber: 3) == WEXDayOfWeek.thursday)
        XCTAssertTrue(WEXDayOfWeek(zeroBasedDayNumber: 4) == WEXDayOfWeek.friday)
        XCTAssertTrue(WEXDayOfWeek(zeroBasedDayNumber: 5) == WEXDayOfWeek.saturday)
        XCTAssertTrue(WEXDayOfWeek(zeroBasedDayNumber: 6) == WEXDayOfWeek.sunday)
        XCTAssertNil(WEXDayOfWeek(zeroBasedDayNumber: 7))
    }
    
    func test_initialise_from_traditional_number() {
        XCTAssertNil(WEXDayOfWeek(traditionalDayNumber: 0))
        XCTAssertTrue(WEXDayOfWeek(traditionalDayNumber: 1) == WEXDayOfWeek.sunday)
        XCTAssertTrue(WEXDayOfWeek(traditionalDayNumber: 2) == WEXDayOfWeek.monday)
        XCTAssertTrue(WEXDayOfWeek(traditionalDayNumber: 3) == WEXDayOfWeek.tuesday)
        XCTAssertTrue(WEXDayOfWeek(traditionalDayNumber: 4) == WEXDayOfWeek.wednesday)
        XCTAssertTrue(WEXDayOfWeek(traditionalDayNumber: 5) == WEXDayOfWeek.thursday)
        XCTAssertTrue(WEXDayOfWeek(traditionalDayNumber: 6) == WEXDayOfWeek.friday)
        XCTAssertTrue(WEXDayOfWeek(traditionalDayNumber: 7) == WEXDayOfWeek.saturday)
    }
    
    
    func test_initialise_from_name() {
        XCTAssertTrue(WEXDayOfWeek(nameOfDay: "mond") == WEXDayOfWeek.monday)
        XCTAssertTrue(WEXDayOfWeek(nameOfDay: "TUES") == WEXDayOfWeek.tuesday)
        XCTAssertTrue(WEXDayOfWeek(nameOfDay: "We") == WEXDayOfWeek.wednesday)
        XCTAssertTrue(WEXDayOfWeek(nameOfDay: "tH") == WEXDayOfWeek.thursday)
        XCTAssertTrue(WEXDayOfWeek(nameOfDay: "friday") == WEXDayOfWeek.friday)
        XCTAssertTrue(WEXDayOfWeek(nameOfDay: "satUrday") == WEXDayOfWeek.saturday)
        XCTAssertTrue(WEXDayOfWeek(nameOfDay: "sun") == WEXDayOfWeek.sunday)
        XCTAssertNil(WEXDayOfWeek(nameOfDay: "zebra"))
    }
    
    
    
    func test_isWeekend() {
        XCTAssertFalse(WEXDayOfWeek(zeroBasedDayNumber: 0)!.isWeekend)
        XCTAssertFalse(WEXDayOfWeek(zeroBasedDayNumber: 1)!.isWeekend)
        XCTAssertFalse(WEXDayOfWeek(zeroBasedDayNumber: 2)!.isWeekend)
        XCTAssertFalse(WEXDayOfWeek(zeroBasedDayNumber: 3)!.isWeekend)
        XCTAssertFalse(WEXDayOfWeek(zeroBasedDayNumber: 4)!.isWeekend)
        XCTAssertTrue(WEXDayOfWeek(zeroBasedDayNumber: 5)!.isWeekend)
        XCTAssertTrue(WEXDayOfWeek(zeroBasedDayNumber: 6)!.isWeekend)
    }
    
    func test_longSymbols() {
        XCTAssertEqual(WEXDayOfWeek.monday.longSymbol, "Monday")
        XCTAssertEqual(WEXDayOfWeek.tuesday.longSymbol, "Tuesday")
        XCTAssertEqual(WEXDayOfWeek.wednesday.longSymbol, "Wednesday")
        XCTAssertEqual(WEXDayOfWeek.thursday.longSymbol, "Thursday")
        XCTAssertEqual(WEXDayOfWeek.friday.longSymbol, "Friday")
        XCTAssertEqual(WEXDayOfWeek.saturday.longSymbol, "Saturday")
        XCTAssertEqual(WEXDayOfWeek.sunday.longSymbol, "Sunday")
    }
    
    func test_mediumSymbols() {
        XCTAssertEqual(WEXDayOfWeek.monday.mediumSymbol, "Mon")
        XCTAssertEqual(WEXDayOfWeek.tuesday.mediumSymbol, "Tue")
        XCTAssertEqual(WEXDayOfWeek.wednesday.mediumSymbol, "Wed")
        XCTAssertEqual(WEXDayOfWeek.thursday.mediumSymbol, "Thu")
        XCTAssertEqual(WEXDayOfWeek.friday.mediumSymbol, "Fri")
        XCTAssertEqual(WEXDayOfWeek.saturday.mediumSymbol, "Sat")
        XCTAssertEqual(WEXDayOfWeek.sunday.mediumSymbol, "Sun")
    }
    
    func test_shortSymbols() {
        XCTAssertEqual(WEXDayOfWeek.monday.shortSymbol, "M")
        XCTAssertEqual(WEXDayOfWeek.tuesday.shortSymbol, "T")
        XCTAssertEqual(WEXDayOfWeek.wednesday.shortSymbol, "W")
        XCTAssertEqual(WEXDayOfWeek.thursday.shortSymbol, "T")
        XCTAssertEqual(WEXDayOfWeek.friday.shortSymbol, "F")
        XCTAssertEqual(WEXDayOfWeek.saturday.shortSymbol, "S")
        XCTAssertEqual(WEXDayOfWeek.sunday.shortSymbol, "S")
    }
    
    func test_twoLetterSymbos() {
        XCTAssertEqual(WEXDayOfWeek.monday.twoLetterSymbol, "MO")
        XCTAssertEqual(WEXDayOfWeek.tuesday.twoLetterSymbol, "TU")
        XCTAssertEqual(WEXDayOfWeek.wednesday.twoLetterSymbol, "WE")
        XCTAssertEqual(WEXDayOfWeek.thursday.twoLetterSymbol, "TH")
        XCTAssertEqual(WEXDayOfWeek.friday.twoLetterSymbol, "FR")
        XCTAssertEqual(WEXDayOfWeek.saturday.twoLetterSymbol, "SA")
        XCTAssertEqual(WEXDayOfWeek.sunday.twoLetterSymbol, "SU")
    }
    
    func test_zeroBasedNumber() {
        XCTAssertEqual(WEXDayOfWeek.monday.zeroBasedDayNumber, 0)
        XCTAssertEqual(WEXDayOfWeek.tuesday.zeroBasedDayNumber, 1)
        XCTAssertEqual(WEXDayOfWeek.wednesday.zeroBasedDayNumber, 2)
        XCTAssertEqual(WEXDayOfWeek.thursday.zeroBasedDayNumber, 3)
        XCTAssertEqual(WEXDayOfWeek.friday.zeroBasedDayNumber, 4)
        XCTAssertEqual(WEXDayOfWeek.saturday.zeroBasedDayNumber, 5)
        XCTAssertEqual(WEXDayOfWeek.sunday.zeroBasedDayNumber, 6)
    }
    
    func test_traditionalNumber() {
        XCTAssertEqual(WEXDayOfWeek.monday.traditionalDayNumber, 2)
        XCTAssertEqual(WEXDayOfWeek.tuesday.traditionalDayNumber, 3)
        XCTAssertEqual(WEXDayOfWeek.wednesday.traditionalDayNumber, 4)
        XCTAssertEqual(WEXDayOfWeek.thursday.traditionalDayNumber, 5)
        XCTAssertEqual(WEXDayOfWeek.friday.traditionalDayNumber, 6)
        XCTAssertEqual(WEXDayOfWeek.saturday.traditionalDayNumber, 7)
        XCTAssertEqual(WEXDayOfWeek.sunday.traditionalDayNumber, 1)
    }
}
