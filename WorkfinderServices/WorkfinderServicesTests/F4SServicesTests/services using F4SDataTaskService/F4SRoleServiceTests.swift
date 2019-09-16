
import XCTest
import WorkfinderCommon
@testable import WorkfinderServices

class F4SRoleServiceTests: XCTestCase {
    
    func test_getRoleForCompany_with_success_result() {
        let role = F4SRoleJson(uuid: "roleUUid", name: "roleName", description: "roleDescription")
        let requiredResult = F4SNetworkResult.success(role)
        let sut = F4SRoleService(configuration: makeTestConfiguration())
        sut.networkTaskFactory = MockF4SNetworkTaskFactory(requiredSuccessResult: requiredResult)
        let expectation = XCTestExpectation(description: "")
        sut.getRoleForCompany(companyUuid: "companyUuid", roleUuid: "roleUUid") { (result) in
            switch result {
            case .error(_):
                XCTFail("This test was designed to have a success result")
            case .success(_):
                break
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func test_getRoleForCompany_with_error_result() {
        let sut = F4SRoleService(configuration: makeTestConfiguration())
        sut.networkTaskFactory = MockF4SNetworkTaskFactory<F4SRoleJson>(requiredNetworkError: F4SNetworkError(error: F4SError.genericError("testing"), attempting: "attempting"))
        let expectation = XCTestExpectation(description: "")
        sut.getRoleForCompany(companyUuid: "companyUuid", roleUuid: "roleUUid") { (result) in
            switch result {
            case .error(_):
                break
            case .success(_):
                XCTFail("This test was designed to have an error result")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

}
