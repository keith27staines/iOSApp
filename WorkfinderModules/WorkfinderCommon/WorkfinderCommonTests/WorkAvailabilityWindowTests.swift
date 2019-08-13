//
//  WorkAvailabilityWindowTests.swift
//  WorkfinderCommonTests
//
//  Created by Keith Dev on 07/08/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import XCTest
@testable import WorkfinderCommon

class WorkAvailabilityWindowTests: XCTestCase {
    
    func test_window_initialis_with_valid_dates() {
        let start = DateComponents(calendar: Calendar.current, year: 2010, month: 7, day: 29).date!
        let end = start.addingTimeInterval(1000)
        let submit = start.addingTimeInterval(-1000)
        let sut = WorkAvailabilityWindow(startDay: start, endDay: end, submission: submit)
        XCTAssertTrue(sut.status == .valid)
    }
    
    func test_window_status_with_missing_start_date() {
        let start: Date? = nil
        let end: Date? = DateComponents(calendar: Calendar.current, year: 2010, month: 7, day: 29).date!
        let submit:Date  = end!.addingTimeInterval(-1000)
        let sut = WorkAvailabilityWindow(startDay: start, endDay: end, submission: submit)
        XCTAssertTrue(sut.status == .invalidStartDateMissing)
    }
    
    func test_window_status_with_missing_start_and_end_date() {
        let start: Date? = nil
        let end: Date? = nil
        let submit:Date  = DateComponents(calendar: Calendar.current, year: 2010, month: 7, day: 29).date!
        let sut = WorkAvailabilityWindow(startDay: start, endDay: end, submission: submit)
        XCTAssertTrue(sut.status == .invalidStartDateMissing)
    }
    
    func test_window_status_with_missing_end_date() {
        let start: Date? = DateComponents(calendar: Calendar.current, year: 2010, month: 7, day: 29).date!
        let end: Date? = nil
        let submit:Date  = start!.addingTimeInterval(-1000)
        let sut = WorkAvailabilityWindow(startDay: start, endDay: end, submission: submit)
        XCTAssertTrue(sut.status == .invalidEndDateMissing)
    }
    
    func test_window_initialise_with_start_after_submit() {
        let start = DateComponents(calendar: Calendar.current, year: 2010, month: 7, day: 29).date!
        let end = start.addingTimeInterval(1000)
        let submit = start.addingTimeInterval(25*3600)
        let sut = WorkAvailabilityWindow(startDay: start, endDay: end, submission: submit)
        XCTAssertTrue(sut.status == .invalidStartsTooEarly)
    }
    
    func test_window_initialise_with_start_after_end() {
        let start = DateComponents(calendar: Calendar.current, year: 2010, month: 7, day: 29).date!
        let end = start.addingTimeInterval(-25*3600)
        let submit = start.addingTimeInterval(-25*3600)
        let sut = WorkAvailabilityWindow(startDay: start, endDay: end, submission: submit)
        XCTAssertTrue(sut.status == .invalidEndsTooEarly)
    }
    
    func test_window_static_isEndDateValid_when_end_earlier_than_submit() {
        let start = DateComponents(calendar: Calendar.current, year: 2010, month: 7, day: 29).date!
        let end = start.addingTimeInterval(-25*3600)
        let submit = start.addingTimeInterval(-25*3600)
        XCTAssertFalse(WorkAvailabilityWindow.isEndDateValid(end: end, start: start, submission: submit))
    }
    
    func test_window_static_isEndDateValid_when_end_earlier_than_start() {
        let start = DateComponents(calendar: Calendar.current, year: 2010, month: 7, day: 29).date!
        let end = start.addingTimeInterval(-25*3600)
        let submit = start.addingTimeInterval(-50*3600)
        XCTAssertFalse(WorkAvailabilityWindow.isEndDateValid(end: end, start: start, submission: submit))
    }
    
    func test_window_static_isEndDateValid_when_valid() {
        let start = DateComponents(calendar: Calendar.current, year: 2010, month: 7, day: 29).date!
        let end = start.addingTimeInterval(25*3600)
        let submit = start.addingTimeInterval(-50*3600)
        XCTAssertTrue(WorkAvailabilityWindow.isEndDateValid(end: end, start: start, submission: submit))
    }
    
    func test_window_static_isStartDateValid_when_start_later_than_submit() {
        let start = DateComponents(calendar: Calendar.current, year: 2010, month: 7, day: 29).date!
        let submit = start.addingTimeInterval(25*3600)
        XCTAssertFalse(WorkAvailabilityWindow.isStartDateValid(start, submission: submit))
    }
    
    func test_window_static_isStartDateValid_when_valid() {
        let start = DateComponents(calendar: Calendar.current, year: 2010, month: 7, day: 29).date!
        let submit = start.addingTimeInterval(-25*3600)
        XCTAssertTrue(WorkAvailabilityWindow.isStartDateValid(start, submission: submit))
    }
}
