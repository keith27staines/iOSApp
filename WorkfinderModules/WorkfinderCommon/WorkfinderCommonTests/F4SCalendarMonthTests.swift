//
//  F4SCalendarMonthTests.swift
//  HoursPicker2Tests
//
//  Created by Keith Dev on 20/03/2018.
//  Copyright © 2018 Workfinder Ltd. All rights reserved.
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
    
    func test_initialise() {
        let day = F4SCalendarDay(cal: f4sCalendar, date: februaryDateNonLeapYear)
        let sut = F4SCalendarMonth(cal: f4sCalendar, date: day.midday)
        XCTAssertTrue(sut.contains(day: day))
    }
    
    func test_veryShortSymbol() {
        let day = F4SCalendarDay(cal: f4sCalendar, date: februaryDateNonLeapYear)
        let sut = F4SCalendarMonth(cal: f4sCalendar, date: day.midday)
        XCTAssertTrue(sut.veryShortMonthSymbol == "F")
    }
    
    func test_next_when_midyear() {
        let day = F4SCalendarDay(cal: f4sCalendar, date: februaryDateNonLeapYear)
        let sut = F4SCalendarMonth(cal: f4sCalendar, date: day.midday)
        XCTAssertTrue(sut.next.monthNumber == 3)
    }
    
    func test_next_after_december() {
        let decemberDay = DateComponents(calendar: Calendar.current, year: 2010, month: 12, day: 1).date!
        let sut = F4SCalendarMonth(cal: f4sCalendar, date: decemberDay)
        XCTAssertTrue(sut.monthNumber == 12)
        XCTAssertTrue(sut.next.monthNumber == 1)
        XCTAssertTrue(sut.next.year == sut.year + 1)
    }
    
    func test_previous_before_january() {
        let januaryDate = DateComponents(calendar: Calendar.current, year: 2010, month: 1, day: 1).date!
        let sut = F4SCalendarMonth(cal: f4sCalendar, date: januaryDate)
        XCTAssertTrue(sut.monthNumber == 1)
        XCTAssertTrue(sut.previous.monthNumber == 12)
        XCTAssertTrue(sut.previous.year == sut.year - 1)
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
