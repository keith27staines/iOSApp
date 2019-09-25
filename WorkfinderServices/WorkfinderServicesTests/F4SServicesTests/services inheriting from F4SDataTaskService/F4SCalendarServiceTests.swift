import XCTest
import WorkfinderCommon
@testable import WorkfinderServices

class F4SCalendarServiceTests: XCTestCase {
    
    func test_initialise() {
        let placementUuid = "placementUuid"
        let sut = F4SAvailabilityService(
            placementUuid: placementUuid,
            configuration: makeTestConfiguration())
        XCTAssertEqual(sut.apiName, "placement/\(placementUuid)")
        XCTAssertEqual(sut.placementUuid, placementUuid)
    }
    
    func test_getAvailability_with_success_result() {
        let placementUuid = "placementUuid"
        let sut = F4SAvailabilityService(
            placementUuid: placementUuid,
            configuration: makeTestConfiguration())
        let returnObject = [F4SAvailabilityPeriodJson(start_date: "2019-08-22", end_date: "2019-08-30", day_time_info: nil)]
        let requiredResult = F4SNetworkResult.success(returnObject)
        sut.networkTaskfactory = MockF4SNetworkTaskFactory(requiredSuccessResult: requiredResult)
        let expectation = XCTestExpectation(description: "")
        sut.getAvailabilityForPlacement() { (result) in
            switch result {
            case .error(_):
                XCTFail("The test was designed to return a success result")
            case .success(let availabilities):
                XCTAssertEqual(availabilities.count,1)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func test_getPartners_with_error_result() {
        let placementUuid = "placementUuid"
        let sut = F4SAvailabilityService(
            placementUuid: placementUuid,
            configuration: makeTestConfiguration())
        let error = F4SNetworkError(error: F4SError.genericError("test error"), attempting: "")
        sut.networkTaskfactory = MockF4SNetworkTaskFactory<[F4SAvailabilityPeriodJson]>(requiredNetworkError: error)
        let expectation = XCTestExpectation(description: "")
        sut.getAvailabilityForPlacement() { (result) in
            switch result {
            case .error(_):
                break
            case .success(_):
                XCTFail("The test was designed to return an error result")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func test_patchAvailability_with_success_result() {
        let placementUuid = "placementUuid"
        let sut = F4SAvailabilityService(
            placementUuid: placementUuid,
            configuration: makeTestConfiguration())
        let period = F4SAvailabilityPeriodJson(start_date: "2019-08-22", end_date: "2019-08-30", day_time_info: nil)
        let periods = F4SAvailabilityPeriodsJson(availability_periods: [period])
        let patch = [period]
        let requiredResult = F4SNetworkResult.success(patch)
        sut.networkTaskfactory = MockF4SNetworkTaskFactory(requiredSuccessResult: requiredResult)
        let expectation = XCTestExpectation(description: "")
        sut.patchAvailabilityForPlacement(availabilityPeriods: periods) { (result) in
            switch result {
            case .error(_):
                XCTFail("The test was designed to return a success result")
            case .success(_):
                break
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
}

