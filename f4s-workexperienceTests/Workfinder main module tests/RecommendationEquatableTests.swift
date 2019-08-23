import XCTest
import WorkfinderCommon
@testable import f4s_workexperience

class F4SRecommendationEquatableTests: XCTestCase {

    func test_F4SRecommendation_EqualityWhenUuidsEqual() {
        let r1 = F4SRecommendation(companyUUID: "0", sortIndex: 0)
        let r2 = F4SRecommendation(companyUUID: "0", sortIndex: 1)
        XCTAssertEqual(r1, r2)
    }
    
    func test_F4SRecommendation_NonEqualityWhenUuidsNotEqual() {
        let r1 = F4SRecommendation(companyUUID: "0", sortIndex: 0)
        let r2 = F4SRecommendation(companyUUID: "1", sortIndex: 1)
        XCTAssertNotEqual(r1, r2)
    }
    
    func test_F4SRecommendation_HashEqualityWhenUuidsEqual() {
        let r1 = F4SRecommendation(companyUUID: "0", sortIndex: 0)
        let r2 = F4SRecommendation(companyUUID: "0", sortIndex: 1)
        XCTAssertEqual(r1.hashValue, r2.hashValue)
    }
    
    func test_F4SRecommendation_HashNonEqualityWhenUuidsNotEqual() {
        let r1 = F4SRecommendation(companyUUID: "0", sortIndex: 0)
        let r2 = F4SRecommendation(companyUUID: "1", sortIndex: 1)
        XCTAssertNotEqual(r1.hashValue, r2.hashValue)
    }

}
