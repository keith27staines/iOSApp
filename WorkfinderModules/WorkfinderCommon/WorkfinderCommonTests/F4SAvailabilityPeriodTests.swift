//
//  F4SAvailabilityPeriodTests.swift
//  WorkfinderCommonTests
//
//  Created by Keith Dev on 09/08/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import XCTest
@testable import WorkfinderCommon

class F4SAvailabilityPeriodTests: XCTestCase {
    let iosCalendar = Calendar.current
    let f4sCalendar = F4SCalendar()
    var firstDate: Date!
    var lastDate: Date!
    var firstDay: F4SCalendarDay!
    var lastDay: F4SCalendarDay!
    var daysAndHours: F4SDaysAndHoursModel!

    override func setUp() {
        firstDate = DateComponents(calendar: Calendar.workfinderCalendar, year: 2000, month: 10, day: 27).date!
        lastDate = DateComponents(calendar: Calendar.workfinderCalendar, year: 2000, month: 11, day: 15).date!
        firstDay  = F4SCalendarDay(cal: f4sCalendar, date: firstDate)
        lastDay  = F4SCalendarDay(cal: f4sCalendar, date: lastDate)
        daysAndHours = F4SDaysAndHoursModel()
    }
    
    override func tearDown() {
        firstDate = nil
        lastDate = nil
        firstDay =  nil
        lastDay = nil
        daysAndHours = nil
    }
    
    func test_initialise() {
        let sut = F4SAvailabilityPeriod(firstDay: firstDay, lastDay: lastDay, daysAndHours: daysAndHours)
        XCTAssertTrue(sut.firstDay == firstDay)
        XCTAssertTrue(sut.lastDay == lastDay)
        XCTAssertTrue(sut.daysAndHours === daysAndHours)
    }
    
    func test_makeAvailabilityPeriodJson() {
        let sut = F4SAvailabilityPeriod(firstDay: firstDay, lastDay: lastDay, daysAndHours: daysAndHours)
        let json = sut.makeAvailabilityPeriodJson()
        XCTAssertEqual(json.start_date, "2000-10-27")
        XCTAssertEqual(json.end_date, "2000-11-15")
        XCTAssertTrue(json.day_time_info!.count == 5)
    }
    
    func test_initalise_from_availabilityPeriodJson() {
        let daysAndHours = [
            F4SDayTimeInfoJson(day: F4SDayOfWeek.friday, hourType: F4SHoursType.am)
        ]
        let availability = F4SAvailabilityPeriodJson(start_date: "2000-10-27", end_date: "2000-11-15", day_time_info: daysAndHours)
        let sut = F4SAvailabilityPeriod(availabilityPeriodJson: availability)
        let s: [F4SDayAndHourSelection] = (sut.daysAndHours?.allDays.filter({ (d) -> Bool in
            d.dayIsSelected == true
        }))!
        XCTAssertEqual(s.count, 1)
        XCTAssertEqual(s.first!.dayOfWeek, .friday)
        XCTAssertEqual(s.first!.hoursType, .am)
        XCTAssertEqual(sut.firstDay?.dayOfMonth, 27)
        XCTAssertEqual(sut.lastDay?.dayOfMonth, 15)
    }
    
    func test_nullify_interval_when_firstDay_in_future() {
        let dateToday = firstDate.addingTimeInterval(-48*3600)
        firstDay.dateToday = dateToday
        lastDay.dateToday = dateToday
        let sut = F4SAvailabilityPeriod(firstDay: firstDay, lastDay: lastDay, daysAndHours: daysAndHours)
        let modifiedSut = sut.nullifyingInvalidStartOrEndDates()
        XCTAssertEqual(modifiedSut.firstDay, firstDay)
        XCTAssertEqual(modifiedSut.lastDay, lastDay)
        XCTAssertNotNil(modifiedSut.daysAndHours)
    }
    
    func test_nullify_interval_when_firstDay_before_today_and_last_day_after_today() {
        let dateToday = firstDate.addingTimeInterval(48*3600)
        firstDay.dateToday = dateToday
        lastDay.dateToday = dateToday
        let sut = F4SAvailabilityPeriod(firstDay: firstDay, lastDay: lastDay, daysAndHours: daysAndHours)
        let modifiedSut = sut.nullifyingInvalidStartOrEndDates()
        XCTAssertNil(modifiedSut.firstDay)
        XCTAssertTrue(modifiedSut.lastDay  == lastDay)
        XCTAssertNotNil(modifiedSut.daysAndHours)
    }
    
    func test_nullify_interval_when_lastDay_before_today() {
        let dateToday = lastDate.addingTimeInterval(48*3600)
        firstDay.dateToday = dateToday
        lastDay.dateToday = dateToday
        let sut = F4SAvailabilityPeriod(firstDay: firstDay, lastDay: lastDay, daysAndHours: daysAndHours)
        let modifiedSut = sut.nullifyingInvalidStartOrEndDates()
        XCTAssertNil(modifiedSut.firstDay)
        XCTAssertNil(modifiedSut.lastDay)
        XCTAssertNotNil(modifiedSut.daysAndHours)
    }
}

class F4SAvailabilityPeriodJsonTests: XCTestCase {
    
    func test_initialise_without_values() {
        let sut = F4SAvailabilityPeriodJson()
        XCTAssertNil(sut.start_date)
        XCTAssertNil(sut.end_date)
        XCTAssertTrue(sut.day_time_info?.count==5)
    }
    
    func test_initialise_with_values() {
        let daysAndHours = [
            F4SDayTimeInfoJson(day: F4SDayOfWeek.friday, hourType: F4SHoursType.am)
        ]
        let sut = F4SAvailabilityPeriodJson(start_date: "2000-10-27", end_date: "2000-11-15", day_time_info: daysAndHours)
        
        XCTAssertTrue(sut.start_date == "2000-10-27")
        XCTAssertTrue(sut.end_date == "2000-11-15")
        XCTAssertTrue(sut.day_time_info?.count == 1)
        XCTAssertTrue(sut.day_time_info?.first?.day == "FR")
    }
}

class F4SDayTimeInfoJsonTests: XCTestCase {
    func test_initialise_with_F4SDayOfWeek() {
        let sut = F4SDayTimeInfoJson(day: .friday, hourType: .am)
        XCTAssertTrue(sut.day == "FR")
        XCTAssertTrue(sut.time == "am")
    }
    
    func test_initialise_with_F4SDayAndHourSelection() {
        let selection = F4SDayAndHourSelection(dayIsSelected: true, dayOfWeek: F4SDayOfWeek.monday, hoursType: F4SHoursType.pm,contiguousPeriods:nil)
        let sut = F4SDayTimeInfoJson(dayAndHours: selection)
        XCTAssertTrue(sut.day == "MO" && sut.time == "pm")
    }
}

