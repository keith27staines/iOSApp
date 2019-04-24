//
//  F4SDisplayableMonth.swift
//  HoursPicker2Tests
//
//  Created by Keith Dev on 20/03/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import XCTest
@testable import WorkfinderCommon

class F4SDisplayableMonthTests: XCTestCase {
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
        let displayableMonth = F4SDisplayableMonth(containing: day.nextDay)
        XCTAssertEqual(displayableMonth.month.days.count, 29)
    }
    
    func testNilLeadingDays() {
        let day = F4SCalendarDay(cal: f4sCalendar, date: februaryDateLeapYear)
        let displayableMonth = F4SDisplayableMonth(containing: day.nextDay)
        XCTAssertNil(displayableMonth.leadingDays)
    }
    
    func testTrailingDays() {
        let day = F4SCalendarDay(cal: f4sCalendar, date: februaryDateLeapYear)
        let displayableMonth = F4SDisplayableMonth(containing: day.nextDay)
        XCTAssertEqual(displayableMonth.trailingDays!.count, 6)
    }
    
    func testFirstDayWithNoLeading() {
        let day = F4SCalendarDay(cal: f4sCalendar, date: februaryDateLeapYear)
        let displayableMonth = F4SDisplayableMonth(containing: day.nextDay)
        XCTAssertEqual(displayableMonth.firstDay, displayableMonth.month.firstDay)
    }
    
    func testLastDay() {
        let day = F4SCalendarDay(cal: f4sCalendar, date: februaryDateLeapYear)
        let displayableMonth = F4SDisplayableMonth(containing: day.nextDay)
        XCTAssertEqual(displayableMonth.lastDay, displayableMonth.trailingDays!.last)
    }
    
    func testLeadingDays() {
        let day = F4SCalendarDay(cal: f4sCalendar, date: februaryDateNonLeapYear)
        let displayableMonth = F4SDisplayableMonth(containing: day.nextDay)
        XCTAssertEqual(displayableMonth.leadingDays!.count, 2)
    }
    
    func testFirstDayWithLeading() {
        let day = F4SCalendarDay(cal: f4sCalendar, date: februaryDateNonLeapYear)
        let displayableMonth = F4SDisplayableMonth(containing: day.nextDay)
        XCTAssertEqual(displayableMonth.firstDay, displayableMonth.leadingDays?.first)
    }
    
    func testMonthNumber() {
        let day = F4SCalendarDay(cal: f4sCalendar, date: februaryDateNonLeapYear)
        let displayableMonth = F4SDisplayableMonth(containing: day.nextDay)
        XCTAssertEqual(displayableMonth.monthNumber, 2)
    }
    
    func testMonthContains() {
        let day = F4SCalendarDay(cal: f4sCalendar, date: februaryDateNonLeapYear)
        let displayableMonth = F4SDisplayableMonth(containing: day)
        XCTAssertTrue(displayableMonth.monthContains(day: day))
    }
    
}
