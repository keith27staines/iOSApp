import XCTest
@testable import WorkfinderCommon

class F4SRecommendationTests: XCTestCase {

    func test_initialise() {
        let sut = F4SRecommendation(companyUUID: "uuid", sortIndex: 9)
        XCTAssertEqual(sut.uuid, "uuid")
        XCTAssertEqual(sut.index,9)
    }
    
    func test_initialise_from_recommendation() {
        let recommendation = F4SRecommendation(companyUUID: "uuid", sortIndex: 9)
        let copy = F4SRecommendation(recommendation: recommendation)
        XCTAssertEqual(recommendation, copy)
    }
    
    func test_hash_when_uuids_equal_sort_indexes_differ() {
        var hasher1 = Hasher()
        var hasher2 = Hasher()
        let sut1 = F4SRecommendation(companyUUID: "uuid", sortIndex: 9)
        let sut2 = F4SRecommendation(companyUUID: "uuid", sortIndex: 10)
        sut1.hash(into: &hasher1)
        sut2.hash(into: &hasher2)
        XCTAssertEqual(hasher1.finalize(), hasher2.finalize())
    }
    
    func test_hash_when_uuids_not_equal() {
        var hasher1 = Hasher()
        var hasher2 = Hasher()
        let sut1 = F4SRecommendation(companyUUID: "uuid1", sortIndex: 9)
        let sut2 = F4SRecommendation(companyUUID: "uuid2", sortIndex: 10)
        sut1.hash(into: &hasher1)
        sut2.hash(into: &hasher2)
        XCTAssertNotEqual(hasher1.finalize(), hasher2.finalize())
    }

}
