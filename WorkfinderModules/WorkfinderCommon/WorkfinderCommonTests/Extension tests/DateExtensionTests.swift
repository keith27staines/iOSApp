//
//  DateExtensionTests.swift
//  WorkfinderCommonTests
//
//  Created by Keith Dev on 07/08/2019.
//  Copyright © 2019 Workfinder Ltd. All rights reserved.
//

import XCTest
@testable import WorkfinderCommon

class DateExtensionTests: XCTestCase {
    
    let calendar = Calendar.workfinderCalendar

    func test_date_isEqualToDate_when_true() {
        let date = Date()
        XCTAssertTrue(date.equalToDate(dateToCompare: date))
    }
    
    func test_date_isEqualToDate_when_false() {
        let date = Date()
        XCTAssertFalse(date.equalToDate(dateToCompare: date.addingTimeInterval(1)))
    }
    
    func test_date_dateIsGreaterThanDate_when_identical() {
        let date = Date()
        XCTAssertFalse(date.isGreaterThanDate(dateToCompare: date))
    }
    
    func test_date_test_date_dateIsGreaterThanDate_when_true() {
        let date1 = Date()
        let date2 = date1.addingTimeInterval(-1)
        XCTAssertTrue(date1.isGreaterThanDate(dateToCompare: date2))
    }
    
    func test_date_test_date_dateIsGreaterThanDate_when_false() {
        let date1 = Date()
        let date2 = date1.addingTimeInterval(1)
        XCTAssertFalse(date1.isGreaterThanDate(dateToCompare: date2))
    }
    
    func test_date_test_date_dateIsLessThanDate_when_true() {
        let date1 = Date()
        let date2 = date1.addingTimeInterval(1)
        XCTAssertTrue(date1.isLessThanDate(dateToCompare: date2))
    }
    
    func test_date_test_date_dateIsLessThanDate_when_false() {
        let date1 = Date()
        let date2 = date1.addingTimeInterval(-1)
        XCTAssertFalse(date1.isLessThanDate(dateToCompare: date2))
    }
    
    func test_date_rfc3339UtcDateFormatter() {
        let date = DateComponents(calendar: calendar, year: 2010, month: 7, day: 23).date!
        XCTAssertEqual(date.dateToStringRfc3339(), "2010-07-23T00:00:00Z")
    }
    
    func test_date_rfc3339UtcDateFormatter_without_subseconds() {
        let date = DateComponents(calendar: calendar, year: 2010, month: 7, day: 23, hour: 3, minute: 9, second: 27).date!
        XCTAssertTrue(date.dateToStringRfc3339() == "2010-07-23T03:09:27Z")
    }
    
    func test_date_rfc3339UtcDateFormatter_with_subseconds() {
        let date = DateComponents(calendar: calendar, year: 2010, month: 7, day: 23, hour: 3, minute: 9, second: 27).date!.addingTimeInterval(0.1)
        XCTAssertTrue(date.dateToStringRfc3339() == "2010-07-23T03:09:27Z")
    }
    
    func test_date_static_rfc3339UtcDateFormatter_with_subseconds() {
        let date = DateComponents(calendar: calendar, year: 2010, month: 7, day: 23, hour: 3, minute: 9, second: 27).date!
        let date2 = Date.dateFromRfc3339(string: "2010-07-23T03:09:27Z")
        XCTAssertEqual(date, date2)
    }
    
    func test_date_static_rfc3339UtcDateFormatter() {
        let date = DateComponents(calendar: calendar, year: 2010, month: 7, day: 23, hour: 3, minute: 9, second: 27).date!
        let df = Date.DateFormatters.rfc3339UtcDateFormatter
        XCTAssertTrue(df.string(from: date) == "2010-07-23")
        XCTAssertTrue(date.rfc3339UtcDate == "2010-07-23")
    }
    
    func test_date_static_rfc3339UtcDateTimeSubsecondFormatter() {
        let date = DateComponents(calendar: calendar, year: 2010, month: 7, day: 23, hour: 3, minute: 9, second: 27).date!
        let df = Date.DateFormatters.rfc3339UtcDateTimeSubsecondFormatter
        XCTAssertTrue(df.string(from: date) == "2010-07-23T03:09:27.000000Z")
        print(date.rfc3339UtcDateTime)
        XCTAssertTrue(date.rfc3339UtcDateTime == "2010-07-23T03:09:27Z")
    }
    
    func test_date_static_workfinderDateString() {
        let dateString = "2020-12-31"
        let date = Date.dateFromRfc3339(string: dateString)!
        XCTAssertEqual(date.workfinderDateString, date.rfc3339UtcDate)
        XCTAssertEqual(date.workfinderDateString, dateString)
    }
}
