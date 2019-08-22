
import XCTest
import WorkfinderCommon
import WorkfinderNetworking
@testable import WorkfinderServices

class F4SVoucherServiceTests: XCTestCase {

    func test_initialise() {
        let sut = F4SVoucherVerificationService(placementUuid: "placementUuid", voucherCode: "voucherCode")
        XCTAssertEqual(sut.placementUuid, "placementUuid")
        XCTAssertEqual(sut.voucherCode, "voucherCode")
    }

}
