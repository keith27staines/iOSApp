//
//  F4SCalendar.swift
//  F4SCalendar
//
//  Created by Keith Dev on 15/03/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import XCTest
@testable import WorkfinderCommon

class F4SCalendarTests: XCTestCase {
    
    var februaryDateLeapYear: Date!    // Midday 1st February of a leap year
    var februaryDateNonLeapYear: Date! // Midday 1st February of non leap year
    var f4sCalendar: F4SCalendar!
    
    func makeFirstFebruaryMiddayDate(year: Int) -> Date {
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = 2   // February
        dateComponents.day = 1     // 1st February
        dateComponents.hour = 12   // Midday 1stFebruary
        let calendar = Calendar(identifier: .gregorian)
        return calendar.date(from: dateComponents)!
    }
    
    override func setUp() {
        super.setUp()
        februaryDateLeapYear = makeFirstFebruaryMiddayDate(year: 2016)
        februaryDateNonLeapYear = makeFirstFebruaryMiddayDate(year: 2017)
        f4sCalendar = F4SCalendar()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        f4sCalendar = nil
    }
    
    func testFebFirstDayNumber() {
        XCTAssertEqual(1,f4sCalendar.dayNumber(date: februaryDateNonLeapYear))
    }
    
    func testDayOfWeek() {
        let dayOfWeek = f4sCalendar.dayOfWeekContaining(date: februaryDateNonLeapYear)
        XCTAssertEqual(dayOfWeek, F4SDayOfWeek.wednesday)
    }
    
    func testMonthNumber() {
        let monthNumber = f4sCalendar.monthNumber(date: februaryDateNonLeapYear)
        XCTAssertEqual(monthNumber, 2)
    }
    
    func testMonthNumberLastDayFebruaryInLeapYear() {
        let lastDay = februaryDateLeapYear.addingTimeInterval(28*24*3600)
        let monthNumber = f4sCalendar.monthNumber(date: lastDay )
        XCTAssertEqual(monthNumber, 2)
    }
    
    func testMonthNumberDayAfterLastDayFebruaryInLeapYear() {
        let lastDay = februaryDateLeapYear.addingTimeInterval(29*24*3600)
        let monthNumber = f4sCalendar.monthNumber(date: lastDay )
        XCTAssertEqual(monthNumber, 3)
    }
    
    func testMonthNumberDayAfterLastDayFebruaryInNonLeapYear() {
        let lastDay = februaryDateNonLeapYear.addingTimeInterval(28*24*3600)
        let monthNumber = f4sCalendar.monthNumber(date: lastDay )
        XCTAssertEqual(monthNumber, 3)
    }
}













