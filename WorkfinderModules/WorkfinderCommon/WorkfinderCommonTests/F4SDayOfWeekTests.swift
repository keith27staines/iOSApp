//
//  F4SDayOfWeekTests.swift
//  WorkfinderCommonTests
//
//  Created by Keith Dev on 12/08/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import XCTest
@testable import WorkfinderCommon

class F4SDayOfWeekTests : XCTestCase {
    func test_initialise_from_zero_based_number() {
        XCTAssertTrue(F4SDayOfWeek(zeroBasedDayNumber: 0) == F4SDayOfWeek.monday)
        XCTAssertTrue(F4SDayOfWeek(zeroBasedDayNumber: 1) == F4SDayOfWeek.tuesday)
        XCTAssertTrue(F4SDayOfWeek(zeroBasedDayNumber: 2) == F4SDayOfWeek.wednesday)
        XCTAssertTrue(F4SDayOfWeek(zeroBasedDayNumber: 3) == F4SDayOfWeek.thursday)
        XCTAssertTrue(F4SDayOfWeek(zeroBasedDayNumber: 4) == F4SDayOfWeek.friday)
        XCTAssertTrue(F4SDayOfWeek(zeroBasedDayNumber: 5) == F4SDayOfWeek.saturday)
        XCTAssertTrue(F4SDayOfWeek(zeroBasedDayNumber: 6) == F4SDayOfWeek.sunday)
        XCTAssertNil(F4SDayOfWeek(zeroBasedDayNumber: 7))
    }
    
    func test_initialise_from_traditional_number() {
        XCTAssertNil(F4SDayOfWeek(traditionalDayNumber: 0))
        XCTAssertTrue(F4SDayOfWeek(traditionalDayNumber: 1) == F4SDayOfWeek.sunday)
        XCTAssertTrue(F4SDayOfWeek(traditionalDayNumber: 2) == F4SDayOfWeek.monday)
        XCTAssertTrue(F4SDayOfWeek(traditionalDayNumber: 3) == F4SDayOfWeek.tuesday)
        XCTAssertTrue(F4SDayOfWeek(traditionalDayNumber: 4) == F4SDayOfWeek.wednesday)
        XCTAssertTrue(F4SDayOfWeek(traditionalDayNumber: 5) == F4SDayOfWeek.thursday)
        XCTAssertTrue(F4SDayOfWeek(traditionalDayNumber: 6) == F4SDayOfWeek.friday)
        XCTAssertTrue(F4SDayOfWeek(traditionalDayNumber: 7) == F4SDayOfWeek.saturday)
    }
    
    
    func test_initialise_from_name() {
        XCTAssertTrue(F4SDayOfWeek(nameOfDay: "mond") == F4SDayOfWeek.monday)
        XCTAssertTrue(F4SDayOfWeek(nameOfDay: "TUES") == F4SDayOfWeek.tuesday)
        XCTAssertTrue(F4SDayOfWeek(nameOfDay: "We") == F4SDayOfWeek.wednesday)
        XCTAssertTrue(F4SDayOfWeek(nameOfDay: "tH") == F4SDayOfWeek.thursday)
        XCTAssertTrue(F4SDayOfWeek(nameOfDay: "friday") == F4SDayOfWeek.friday)
        XCTAssertTrue(F4SDayOfWeek(nameOfDay: "satUrday") == F4SDayOfWeek.saturday)
        XCTAssertTrue(F4SDayOfWeek(nameOfDay: "sun") == F4SDayOfWeek.sunday)
        XCTAssertNil(F4SDayOfWeek(nameOfDay: "zebra"))
    }
    
    
    
    func test_isWeekend() {
        XCTAssertFalse(F4SDayOfWeek(zeroBasedDayNumber: 0)!.isWeekend)
        XCTAssertFalse(F4SDayOfWeek(zeroBasedDayNumber: 1)!.isWeekend)
        XCTAssertFalse(F4SDayOfWeek(zeroBasedDayNumber: 2)!.isWeekend)
        XCTAssertFalse(F4SDayOfWeek(zeroBasedDayNumber: 3)!.isWeekend)
        XCTAssertFalse(F4SDayOfWeek(zeroBasedDayNumber: 4)!.isWeekend)
        XCTAssertTrue(F4SDayOfWeek(zeroBasedDayNumber: 5)!.isWeekend)
        XCTAssertTrue(F4SDayOfWeek(zeroBasedDayNumber: 6)!.isWeekend)
    }
    
    func test_longSymbols() {
        XCTAssertEqual(F4SDayOfWeek.monday.longSymbol, "Monday")
        XCTAssertEqual(F4SDayOfWeek.tuesday.longSymbol, "Tuesday")
        XCTAssertEqual(F4SDayOfWeek.wednesday.longSymbol, "Wednesday")
        XCTAssertEqual(F4SDayOfWeek.thursday.longSymbol, "Thursday")
        XCTAssertEqual(F4SDayOfWeek.friday.longSymbol, "Friday")
        XCTAssertEqual(F4SDayOfWeek.saturday.longSymbol, "Saturday")
        XCTAssertEqual(F4SDayOfWeek.sunday.longSymbol, "Sunday")
    }
    
    func test_mediumSymbols() {
        XCTAssertEqual(F4SDayOfWeek.monday.mediumSymbol, "Mon")
        XCTAssertEqual(F4SDayOfWeek.tuesday.mediumSymbol, "Tue")
        XCTAssertEqual(F4SDayOfWeek.wednesday.mediumSymbol, "Wed")
        XCTAssertEqual(F4SDayOfWeek.thursday.mediumSymbol, "Thu")
        XCTAssertEqual(F4SDayOfWeek.friday.mediumSymbol, "Fri")
        XCTAssertEqual(F4SDayOfWeek.saturday.mediumSymbol, "Sat")
        XCTAssertEqual(F4SDayOfWeek.sunday.mediumSymbol, "Sun")
    }
    
    func test_shortSymbols() {
        XCTAssertEqual(F4SDayOfWeek.monday.shortSymbol, "M")
        XCTAssertEqual(F4SDayOfWeek.tuesday.shortSymbol, "T")
        XCTAssertEqual(F4SDayOfWeek.wednesday.shortSymbol, "W")
        XCTAssertEqual(F4SDayOfWeek.thursday.shortSymbol, "T")
        XCTAssertEqual(F4SDayOfWeek.friday.shortSymbol, "F")
        XCTAssertEqual(F4SDayOfWeek.saturday.shortSymbol, "S")
        XCTAssertEqual(F4SDayOfWeek.sunday.shortSymbol, "S")
    }
    
    func test_twoLetterSymbos() {
        XCTAssertEqual(F4SDayOfWeek.monday.twoLetterSymbol, "MO")
        XCTAssertEqual(F4SDayOfWeek.tuesday.twoLetterSymbol, "TU")
        XCTAssertEqual(F4SDayOfWeek.wednesday.twoLetterSymbol, "WE")
        XCTAssertEqual(F4SDayOfWeek.thursday.twoLetterSymbol, "TH")
        XCTAssertEqual(F4SDayOfWeek.friday.twoLetterSymbol, "FR")
        XCTAssertEqual(F4SDayOfWeek.saturday.twoLetterSymbol, "SA")
        XCTAssertEqual(F4SDayOfWeek.sunday.twoLetterSymbol, "SU")
    }
    
    func test_zeroBasedNumber() {
        XCTAssertEqual(F4SDayOfWeek.monday.zeroBasedDayNumber, 0)
        XCTAssertEqual(F4SDayOfWeek.tuesday.zeroBasedDayNumber, 1)
        XCTAssertEqual(F4SDayOfWeek.wednesday.zeroBasedDayNumber, 2)
        XCTAssertEqual(F4SDayOfWeek.thursday.zeroBasedDayNumber, 3)
        XCTAssertEqual(F4SDayOfWeek.friday.zeroBasedDayNumber, 4)
        XCTAssertEqual(F4SDayOfWeek.saturday.zeroBasedDayNumber, 5)
        XCTAssertEqual(F4SDayOfWeek.sunday.zeroBasedDayNumber, 6)
    }
    
    func test_traditionalNumber() {
        XCTAssertEqual(F4SDayOfWeek.monday.traditionalDayNumber, 2)
        XCTAssertEqual(F4SDayOfWeek.tuesday.traditionalDayNumber, 3)
        XCTAssertEqual(F4SDayOfWeek.wednesday.traditionalDayNumber, 4)
        XCTAssertEqual(F4SDayOfWeek.thursday.traditionalDayNumber, 5)
        XCTAssertEqual(F4SDayOfWeek.friday.traditionalDayNumber, 6)
        XCTAssertEqual(F4SDayOfWeek.saturday.traditionalDayNumber, 7)
        XCTAssertEqual(F4SDayOfWeek.sunday.traditionalDayNumber, 1)
    }
}
