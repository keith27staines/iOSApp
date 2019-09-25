import XCTest
import WorkfinderCommon

class F4SHoursTypeTests: XCTestCase {

    func test_titledDisplayText() {
        XCTAssertEqual(F4SHoursType.am.titledDisplayText, "AM")
        XCTAssertEqual(F4SHoursType.pm.titledDisplayText, "PM")
        XCTAssertEqual(F4SHoursType.all.titledDisplayText, "All day")
        XCTAssertEqual(F4SHoursType.custom.titledDisplayText, "custom")
    }

}
