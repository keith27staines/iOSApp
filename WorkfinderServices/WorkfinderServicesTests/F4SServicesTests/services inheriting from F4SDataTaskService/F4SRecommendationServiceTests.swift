import XCTest
import WorkfinderCommon
import WorkfinderNetworking
@testable import WorkfinderServices

class F4SRecommendationServiceTests : XCTestCase {
    
    func test_initialise() {
        let sut = F4SRecommendationService()
        XCTAssertEqual(sut.apiName, "recommend")
    }
    
    func test_fetch() {
        let sut = F4SRecommendationService()
        let expectedRecommendation = Recommendation(companyUUID: "companyUuid", sortIndex: 0)
        let requiredResult = F4SNetworkResult.success([expectedRecommendation])
        sut.networkTaskfactory = MockF4SNetworkTaskFactory(requiredSuccessResult: requiredResult)
        let expectation = XCTestExpectation(description: "")
        sut.fetch { (result) in
            switch result {
            case .error(_):
                XCTFail("The test was designed to return a success result")
            case .success(let recommendations):
                XCTAssertEqual(recommendations.first!.uuid, expectedRecommendation.uuid!)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
}
