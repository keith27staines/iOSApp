
import XCTest
@testable import WorkfinderCommon

class F4SCalendarDayTests: XCTestCase {

    var februaryDateLeapYear: Date!    // Midday 1st February of a leap year
    var februaryDateNonLeapYear: Date! // Midday 1st February of non leap year
    var f4sCalendar: F4SCalendar!
    
    func makeFirstFebruaryMiddayDate(year: Int) -> Date {
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = 2   // February
        dateComponents.day = 1     // 1st February
        dateComponents.hour = 12   // Midday 1stFebruary
        let calendar = Calendar.workfinderCalendar
        return calendar.date(from: dateComponents)!
    }
    
    override func setUp() {
        super.setUp()
        februaryDateLeapYear = makeFirstFebruaryMiddayDate(year: 2016)
        februaryDateNonLeapYear = makeFirstFebruaryMiddayDate(year: 2017)
        f4sCalendar = F4SCalendar()
    }
    
    func testDayNumberFeb012016() {
        let day = F4SCalendarDay(cal: f4sCalendar, date: februaryDateLeapYear)
        let dayNumber = day.dayOfWeek
        XCTAssertEqual(dayNumber, F4SDayOfWeek.monday)
    }
    
    func testDayNumberFeb012017() {
        let day = F4SCalendarDay(cal: f4sCalendar, date: februaryDateNonLeapYear)
        let dayNumber = day.dayOfWeek
        XCTAssertEqual(dayNumber, F4SDayOfWeek.wednesday)
    }
    
    func testDayOfMonthFeb012017() {
        let day = F4SCalendarDay(cal: f4sCalendar, date: februaryDateNonLeapYear)
        XCTAssertEqual(day.dayOfMonth, 1)
    }
    
    func testDayAfterFeb012017() {
        let day = F4SCalendarDay(cal: f4sCalendar, date: februaryDateNonLeapYear)
        XCTAssertEqual(day.nextDay.dayOfMonth, 2)
    }
    
    func testDayBeforeFeb012017() {
        let day = F4SCalendarDay(cal: f4sCalendar, date: februaryDateNonLeapYear)
        XCTAssertEqual(day.previousDay.dayOfMonth, 31)
    }
    
    func testMonthOfYearFeb012017() {
        let day = F4SCalendarDay(cal: f4sCalendar, date: februaryDateNonLeapYear)
        XCTAssertEqual(day.monthOfYear, 2)
    }
    
    func testEquality() {
        let day1 = F4SCalendarDay(cal: f4sCalendar, date: februaryDateNonLeapYear)
        let day2 = F4SCalendarDay(cal: f4sCalendar, date: februaryDateNonLeapYear)
        XCTAssertEqual(day1, day2)
    }
    
    func testNotEqual() {
        let day1 = F4SCalendarDay(cal: f4sCalendar, date: februaryDateNonLeapYear)
        let day2 = F4SCalendarDay(cal: f4sCalendar, date: februaryDateNonLeapYear)
        XCTAssertNotEqual(day1, day2.nextDay)
    }
    
    func testComparable() {
        let day1 = F4SCalendarDay(cal: f4sCalendar, date: februaryDateNonLeapYear)
        XCTAssertTrue(day1 == day1)
        XCTAssertTrue(day1 < day1.nextDay)
    }
    
    func testSorting() {
        let day = F4SCalendarDay(cal: f4sCalendar, date: februaryDateNonLeapYear)
        let days = [day,day.nextDay,day.previousDay].sorted()
        XCTAssertEqual(days[0], day.previousDay)
        XCTAssertEqual(days[1], day)
        XCTAssertEqual(days[2], day.nextDay)
    }
    
    func test_interval() {
        let sut = F4SCalendarDay(cal: f4sCalendar, date: februaryDateNonLeapYear)
        let interval = sut.interval
        XCTAssertEqual(interval.duration, 86400.0)
        XCTAssertEqual(interval.start.dateToStringRfc3339(), "2017-02-01T00:00:00Z")
    }
    
    func test_isToday() {
        var sut = F4SCalendarDay(cal: f4sCalendar, date: februaryDateNonLeapYear)
        sut.dateToday = februaryDateNonLeapYear
        XCTAssertTrue(sut.isToday)
        XCTAssertFalse(sut.isInPast)
        XCTAssertFalse(sut.isInFuture)
    }
    
    func test_isInFuture() {
        var sut = F4SCalendarDay(cal: f4sCalendar, date: februaryDateNonLeapYear)
        sut.dateToday = februaryDateNonLeapYear.addingTimeInterval(-48*3600)
        XCTAssertFalse(sut.isToday)
        XCTAssertFalse(sut.isInPast)
        XCTAssertTrue(sut.isInFuture)
    }
    
    func test_isInPast() {
        var sut = F4SCalendarDay(cal: f4sCalendar, date: februaryDateNonLeapYear)
        sut.dateToday = februaryDateNonLeapYear.addingTimeInterval(48*3600)
        XCTAssertFalse(sut.isToday)
        XCTAssertTrue(sut.isInPast)
        XCTAssertFalse(sut.isInFuture)
    }
    
    func test_year() {
        let sut = F4SCalendarDay(cal: f4sCalendar, date: februaryDateNonLeapYear)
        XCTAssertTrue(sut.year == 2017)
    }

}
























