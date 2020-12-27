//
//  F4SDisplayableMonth.swift
//  HoursPicker2Tests
//
//  Created by Keith Dev on 20/03/2018.
//  Copyright © 2018 Workfinder Ltd. All rights reserved.
//

import XCTest
@testable import WorkfinderCommon

// Feb 2016 (leap year example month)
// Mon  Tue  Wed  Thu  Fri  Sat  Sun
//  01   02   03   04   05   06   07
//  08   09   10   11   12   13   14
//  15   16   17   18   19   20   21
//  22   23   24   25   26   27   28
//  29   01   02   03   04   05   06

// Feb 2017 (Non leap year example month)
// Mon  Tue  Wed  Thu  Fri  Sat  Sun
//  30   31   01   02   03   04   05
//  06   07   08   09   10   11   12
//  13   14   15   16   17   18   19
//  20   21   22   23   24   25   26
//  27   28   01   02   03   04   05

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
    
    func testleadingDays() {
        let day = F4SCalendarDay(cal: f4sCalendar, date: februaryDateNonLeapYear)
        let displayableMonth = F4SDisplayableMonth(containing: day)
        XCTAssertEqual(displayableMonth.leadingDays?.count, 2)
    }
    
    func test_numberOfDays_is_35() {
        let dateComponents = DateComponents(calendar: Calendar.current, year: 2018, month: 1, day: 1)
        let date = dateComponents.date!
        let calendar = F4SCalendar()
        let displayMonth = F4SDisplayableMonth(cal: calendar, date: date)
        XCTAssertEqual(displayMonth.numberOfDaysToDisplay(), 35)
    }
    
    func test_day_for_row() {
        let day = F4SCalendarDay(cal: f4sCalendar, date: februaryDateNonLeapYear)
        let displayableMonth = F4SDisplayableMonth(containing: day)
        let firstDay = displayableMonth.firstDay
        let lastDay = displayableMonth.lastDay
        XCTAssertEqual(displayableMonth.dayForRow(row: 0), firstDay)
        XCTAssertEqual(displayableMonth.dayForRow(row: 34), lastDay)
    }
    
    func test_leadingDaysContains() {
        let day = F4SCalendarDay(cal: f4sCalendar, date: februaryDateNonLeapYear)
        let displayableMonth = F4SDisplayableMonth(containing: day)
        XCTAssertFalse(displayableMonth.leadingDaysContains(day: displayableMonth.month.firstDay))
        XCTAssertTrue(displayableMonth.leadingDaysContains(day: displayableMonth.month.firstDay.previousDay))
    }
    
    func test_trailingDaysContains() {
        let day = F4SCalendarDay(cal: f4sCalendar, date: februaryDateNonLeapYear)
        let displayableMonth = F4SDisplayableMonth(containing: day)
        XCTAssertFalse(displayableMonth.trailingDaysContains(day: displayableMonth.month.lastDay))
        XCTAssertTrue(displayableMonth.trailingDaysContains(day: displayableMonth.month.lastDay.nextDay))
    }
}
