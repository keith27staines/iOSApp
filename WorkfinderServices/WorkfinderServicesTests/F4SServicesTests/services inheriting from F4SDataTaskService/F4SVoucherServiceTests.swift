
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
    
    func test_verify_with_success() {
        let voucherCode = "voucher-code"
        let placementUuid = "placement-uuid"
        let sut = F4SVoucherVerificationService(placementUuid: placementUuid, voucherCode: voucherCode)
        let returnObject = F4SVoucherValidation(status: "testing", errors: nil)
        let requiredResult = F4SNetworkResult.success(returnObject)
        sut.networkTaskfactory = MockF4SNetworkTaskFactory(requiredSuccessResult: requiredResult)
        let expectation = XCTestExpectation(description: "")
        sut.verify { (result) in
            switch result {
            case .error(_):
                XCTFail("The test was designed to return a success result")
            case .success(let voucherValidation):
                XCTAssertEqual(voucherValidation.status, "testing")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(sut.apiName, "voucher/\(voucherCode)")
        XCTAssertEqual(sut.placementUuid, placementUuid)
    }
    
    func test_verify_with_error() {
        let voucherCode = "voucher-code"
        let placementUuid = "placement-uuid"
        let sut = F4SVoucherVerificationService(placementUuid: placementUuid, voucherCode: voucherCode)
        let error = F4SNetworkError(error: F4SError.genericError(nil), attempting: "something")
        sut.networkTaskfactory = MockF4SNetworkTaskFactory<F4SVoucherValidation>(requiredNetworkError: error)
        let expectation = XCTestExpectation(description: "")
        sut.verify { (result) in
            switch result {
            case .error(let error):
                XCTAssertEqual(error.attempting,"something")
            case .success(_):
                XCTFail("The test was designed to return an error result")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    

}
