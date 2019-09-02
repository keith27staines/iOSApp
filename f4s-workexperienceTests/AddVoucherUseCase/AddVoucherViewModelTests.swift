import XCTest
import WorkfinderCommon
@testable import f4s_workexperience

class AddVoucherViewModelTests: XCTestCase {

    func test_initialise_for_accept_workflow() {
        let sut = AddVoucherViewModel(workflow: .apply)
        XCTAssertEqual(sut.workflow, .apply)
    }

}
