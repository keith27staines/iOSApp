//
//  F4SCalendarWeekTests.swift
//  HoursPicker2Tests
//
//  Created by Keith Dev on 20/03/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import XCTest
@testable import WorkfinderCommon

class F4SCalendarWeekTests: XCTestCase {
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
    
    func testCountDaysInWeek() {
        let day = F4SCalendarDay(cal: f4sCalendar, date: februaryDateLeapYear)
        let week = F4SCalendarWeek(containing: day.nextDay)
        XCTAssertEqual(week.days.count, 7)
    }
    
    func testFirstDayInWeekIsMonday() {
        let day = F4SCalendarDay(cal: f4sCalendar, date: februaryDateLeapYear)
        let week = F4SCalendarWeek(containing: day.nextDay)
        XCTAssertEqual(week.firstDay.dayOfWeek, F4SDayOfWeek.monday)
    }
    
    func testLastDayInWeekIsSunday() {
        let day = F4SCalendarDay(cal: f4sCalendar, date: februaryDateLeapYear)
        let week = F4SCalendarWeek(containing: day.nextDay)
        XCTAssertEqual(week.lastDay.dayOfWeek, F4SDayOfWeek.sunday)
    }
    
    func testInterval() {
        let day = F4SCalendarDay(cal: f4sCalendar, date: februaryDateLeapYear)
        let week = F4SCalendarWeek(containing: day.nextDay)
        let weekInterval = week.interval
        XCTAssertTrue(weekInterval.duration == 7 * 24 * 3600)
    }
    
    func testContains() {
        let day = F4SCalendarDay(cal: f4sCalendar, date: februaryDateLeapYear)
        let week = F4SCalendarWeek(containing: day)
        XCTAssertTrue(week.contains(day: day.nextDay))
    }
    
    func testNotContains() {
        let day = F4SCalendarDay(cal: f4sCalendar, date: februaryDateLeapYear)
        let week = F4SCalendarWeek(containing: day)
        XCTAssertFalse(week.contains(day: day.previousDay))
    }
    
}
