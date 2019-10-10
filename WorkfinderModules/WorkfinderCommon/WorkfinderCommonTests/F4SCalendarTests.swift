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
    
    func test_tap_state_no_taps_yet() {
        let sut = F4SCalendar()
        switch sut.tap {
        case F4SCalendar.Tap.select: break
        default:
            XCTFail("Incorrect state")
        }
    }
    
    func test_first_tap_is_in_past() {
        let firstTapDate = DateComponents(calendar: Calendar.current, year: 2019, month: 8, day: 10).date!
        let sut = F4SCalendar()
        let day1 = F4SCalendarDay(cal: sut, date: firstTapDate)
        sut.threeTapWaltz(day: day1)
        switch sut.tap {
        case F4SCalendar.Tap.select: break
        default:
            XCTFail("Incorrect state")
        }
    }
    
    func test_first_tap_is_in_future() {
        let firstTapDate = DateComponents(calendar: Calendar.current, year: 2119, month: 8, day: 10).date!
        let sut = F4SCalendar()
        let day1 = F4SCalendarDay(cal: sut, date: firstTapDate)
        sut.threeTapWaltz(day: day1)
        switch sut.tap {
        case F4SCalendar.Tap.extend(let day):
            XCTAssertEqual(day, day1)
        default:
            XCTFail("Incorrect state")
        }
    }
    
    func test_second_tap_is_in_the_past() {
        let now = Date()
        let futureDate = now.addingTimeInterval(48*3600)
        let pastDate = now.addingTimeInterval(-48*3600)
        let sut = F4SCalendar()
        let day1 = F4SCalendarDay(cal: sut, date: futureDate)
        let day2 = F4SCalendarDay(cal: sut, date: pastDate)
        sut.threeTapWaltz(day: day1)
        sut.threeTapWaltz(day: day2) // should ignore the second tap because it is in the past
        switch sut.tap {
        case F4SCalendar.Tap.extend(let day):
            XCTAssertEqual(day, day1)
        default:
            XCTFail("Incorrect state")
        }
    }
    
    func test_second_tap_is_in_the_future_after_first_tap() {
        let now = Date()
        let futureDate = now.addingTimeInterval(2*24*3600)
        let furtherFutureDate = now.addingTimeInterval(4*24*3600)
        let sut = F4SCalendar()
        let day1 = F4SCalendarDay(cal: sut, date: futureDate)
        let day2 = F4SCalendarDay(cal: sut, date: furtherFutureDate)
        sut.threeTapWaltz(day: day1)
        sut.threeTapWaltz(day: day2)
        switch sut.tap {
        case F4SCalendar.Tap.clear:
            XCTAssertEqual(sut.firstDay, day1)
            XCTAssertEqual(sut.lastDay, day2)
        default:
            XCTFail("Incorrect state")
        }
    }
    
    func test_third_tap() {
        let now = Date()
        let futureDate = now.addingTimeInterval(2*24*3600)
        let furtherFutureDate = now.addingTimeInterval(4*24*3600)
        let sut = F4SCalendar()
        let day1 = F4SCalendarDay(cal: sut, date: futureDate)
        let day2 = F4SCalendarDay(cal: sut, date: furtherFutureDate)
        sut.threeTapWaltz(day: day1)
        sut.threeTapWaltz(day: day2)
        sut.threeTapWaltz(day: day2)
        switch sut.tap {
        case F4SCalendar.Tap.select:
            XCTAssertNil(sut.firstDay)
            XCTAssertNil(sut.lastDay)
        default:
            XCTFail("Incorrect state")
        }
    }
    
    func test_second_tap_is_same_as_first_tap() {
        let now = Date()
        let futureDate = now.addingTimeInterval(48*3600)
        let sut = F4SCalendar()
        let day1 = F4SCalendarDay(cal: sut, date: futureDate)
        sut.threeTapWaltz(day: day1)
        sut.threeTapWaltz(day: day1)
        switch sut.tap {
        case F4SCalendar.Tap.select:
            XCTAssertNil(sut.firstDay)
            XCTAssertNil(sut.lastDay)
        default:
            XCTFail("Incorrect state")
        }
    }
    
    func test_setSelection() {
        let now = Date()
        let futureDate = now.addingTimeInterval(48*3600)
        let furtherFutureDate = now.addingTimeInterval(64*3600)
        let sut = F4SCalendar()
        let day1 = F4SCalendarDay(cal: sut, date: futureDate)
        let day2 = F4SCalendarDay(cal: sut, date: furtherFutureDate)
        sut.setSelection(firstDay: day1, lastDay: day2)
        XCTAssertEqual(sut.firstDay, day1)
        XCTAssertEqual(sut.lastDay, day2)
    }
    
    func test_toggleSelection() {
        let now = Date()
        let futureDate = now.addingTimeInterval(48*3600)
        let sut = F4SCalendar()
        let day = F4SCalendarDay(cal: sut, date: futureDate)
        sut.toggleSelection(day: day)
        XCTAssertTrue((sut.selectionStates[day.midday] == F4SExtendibleSelectionState.terminal.rawValue))
    }
    
    func test_nextDayAfterDay() {
        let date = DateComponents(calendar: Calendar.workfinderCalendar, year: 2019, month: 8, day: 10).date!
        let sut = F4SCalendar()
        let nextDay = sut.nextDayAfterDayContaining(date: date)
        let dateComponents = Calendar.workfinderCalendar.dateComponents([.year,.month,.day], from:nextDay.start)
        XCTAssertEqual(dateComponents.year, 2019)
        XCTAssertEqual(dateComponents.month, 8)
        XCTAssertEqual(dateComponents.day, 11)
    }
    
    func test_previousDayBeforeDay() {
        let date = DateComponents(calendar: Calendar.workfinderCalendar, year: 2019, month: 8, day: 10).date!
        let sut = F4SCalendar()
        let previousDay = sut.previousDayBeforeDayContaining(date: date)
        let dateComponents = Calendar.workfinderCalendar.dateComponents([.year,.month,.day], from:previousDay.start)
        XCTAssertEqual(dateComponents.year, 2019)
        XCTAssertEqual(dateComponents.month, 8)
        XCTAssertEqual(dateComponents.day, 9)
    }
    
    func test_numberOfDisplayableMonths() {
        let date = DateComponents(calendar: Calendar.workfinderCalendar, year: 2019, month: 8, day: 10).date!
        let sut = F4SCalendar(date: date)
        let month = sut.displayableMonth(index: 0)
        XCTAssertEqual(month.firstDay.monthOfYear, 7)
        XCTAssertEqual(month.firstDay.dayOfMonth, 29)
        XCTAssertEqual(month.lastDay.dayOfMonth,1)
        XCTAssertEqual(month.lastDay.monthOfYear, 9)
    }
    
    func test_intervalForWeekContaining() {
        
    }
}











