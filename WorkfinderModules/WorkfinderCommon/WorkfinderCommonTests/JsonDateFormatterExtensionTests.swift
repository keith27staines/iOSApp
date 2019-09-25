import XCTest
@testable import WorkfinderCommon

class JsonDateFormatterExtensionTests: XCTestCase {
    
    let dateComponents = DateComponents(calendar: Calendar(identifier: Calendar.Identifier.gregorian), timeZone: nil, era: nil, year: 2019, month: 10, day: 30, hour: 17, minute: 18, second: 19, nanosecond: 12000000, weekday: nil, weekdayOrdinal: nil, quarter: nil, weekOfMonth: nil, weekOfYear: nil, yearForWeekOfYear: nil)
    
    let sut = DateFormatter.iso8601Full
    
    func test_dateString_from_date_time_and_timezone() {
        let date = dateComponents.date!
        let dateString = sut.string(from: date)
        XCTAssertEqual(dateString, "2019-10-30T17:18:19.012Z")
    }
    
    func test_dateFromString() {
        let date = sut.date(from: "2019-10-30T17:18:19.012Z")!
        let cal = Calendar(identifier: Calendar.Identifier.gregorian)
        XCTAssertEqual(cal.component(Calendar.Component.year, from: date), 2019)
        XCTAssertEqual(cal.component(Calendar.Component.month, from: date), 10)
        XCTAssertEqual(cal.component(Calendar.Component.day, from: date), 30)
        XCTAssertEqual(cal.component(Calendar.Component.hour, from: date), 17)
        XCTAssertEqual(cal.component(Calendar.Component.minute, from: date), 18)
        XCTAssertEqual(cal.component(Calendar.Component.second, from: date), 19)
        XCTAssertEqual(Int(cal.component(Calendar.Component.nanosecond, from: date))/100000, 120)
    }
}
