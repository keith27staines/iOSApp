import XCTest
@testable import f4s_workexperience

class RecommendationEquatableTests: XCTestCase {

    func test_Recommendation_EqualityWhenUuidsEqual() {
        let r1 = Recommendation(companyUUID: "0", sortIndex: 0)
        let r2 = Recommendation(companyUUID: "0", sortIndex: 1)
        XCTAssertEqual(r1, r2)
    }
    
    func test_Recommendation_NonEqualityWhenUuidsNotEqual() {
        let r1 = Recommendation(companyUUID: "0", sortIndex: 0)
        let r2 = Recommendation(companyUUID: "1", sortIndex: 1)
        XCTAssertNotEqual(r1, r2)
    }
    
    func test_Recommendation_HashEqualityWhenUuidsEqual() {
        let r1 = Recommendation(companyUUID: "0", sortIndex: 0)
        let r2 = Recommendation(companyUUID: "0", sortIndex: 1)
        XCTAssertEqual(r1.hashValue, r2.hashValue)
    }
    
    func test_Recommendation_HashNonEqualityWhenUuidsNotEqual() {
        let r1 = Recommendation(companyUUID: "0", sortIndex: 0)
        let r2 = Recommendation(companyUUID: "1", sortIndex: 1)
        XCTAssertNotEqual(r1.hashValue, r2.hashValue)
    }

}
