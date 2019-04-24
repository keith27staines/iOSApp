//
//  F4SCalendarMonthTests.swift
//  HoursPicker2Tests
//
//  Created by Keith Dev on 20/03/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import XCTest
@testable import WorkfinderCommon

class F4SCalendarMonthTests: XCTestCase {
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
    
    func testCountDaysInMonth() {
        let day = F4SCalendarDay(cal: f4sCalendar, date: februaryDateLeapYear)
        let month = F4SCalendarMonth(containing: day.nextDay)
        XCTAssertEqual(month.days.count, 29)
    }
    
    func testFirstDayInMonth() {
        let day = F4SCalendarDay(cal: f4sCalendar, date: februaryDateLeapYear)
        let month = F4SCalendarMonth(containing: day.nextDay)
        XCTAssertEqual(month.firstDay.dayOfWeek, F4SDayOfWeek.monday)
    }

    func testLastDayInMonth() {
        let day = F4SCalendarDay(cal: f4sCalendar, date: februaryDateLeapYear)
        let month = F4SCalendarMonth(containing: day.nextDay)
        XCTAssertEqual(month.lastDay.dayOfWeek, F4SDayOfWeek.monday)
    }

    func testInterval() {
        let day = F4SCalendarDay(cal: f4sCalendar, date: februaryDateLeapYear)
        let month = F4SCalendarMonth(containing: day.nextDay)
        let monthInterval = month.interval
        XCTAssertTrue(monthInterval.duration == 29 * 24 * 3600)
    }
    
    func testMonthNumber() {
        let day = F4SCalendarDay(cal: f4sCalendar, date: februaryDateLeapYear)
        let month = F4SCalendarMonth(containing: day.nextDay)
        XCTAssertEqual(month.monthNumber, 2)
    }
    
    func testVeryShortMonthSymbol() {
        let day = F4SCalendarDay(cal: f4sCalendar, date: februaryDateLeapYear)
        let month = F4SCalendarMonth(containing: day.nextDay)
        XCTAssertEqual(month.shortMonthSymbol, "Feb")
    }
    
    func testShortMonthSymbol() {
        let day = F4SCalendarDay(cal: f4sCalendar, date: februaryDateLeapYear)
        let month = F4SCalendarMonth(containing: day.nextDay)
        XCTAssertEqual(month.shortMonthSymbol, "Feb")
    }
    
    func testMonthSymbol() {
        let day = F4SCalendarDay(cal: f4sCalendar, date: februaryDateLeapYear)
        let month = F4SCalendarMonth(containing: day.nextDay)
        XCTAssertEqual(month.monthSymbol, "February")
    }
    
    func testYearNumber() {
        let day = F4SCalendarDay(cal: f4sCalendar, date: februaryDateLeapYear)
        let month = F4SCalendarMonth(containing: day.nextDay)
        XCTAssertEqual(month.year, 2016)
    }
    
    func testContains() {
        let day = F4SCalendarDay(cal: f4sCalendar, date: februaryDateLeapYear)
        let month = F4SCalendarMonth(containing: day)
        XCTAssertTrue(month.contains(day: day))
    }
    
    func testNotContains() {
        let day = F4SCalendarDay(cal: f4sCalendar, date: februaryDateLeapYear)
        let month = F4SCalendarMonth(containing: day)
        XCTAssertFalse(month.contains(day: day.previousDay))
    }
    
}
