import XCTest
@testable import f4s_workexperience

class RecommendedCompaniesMergerTests: XCTestCase {

    func testRecommendedCompaniesMerger_localEmpty_RemoteNil() {
        let localFetch = [Recommendation]()
        let serverFetch: [Recommendation]? = nil
        let sut = RecommendedCompaniesMerger(fetchedFromLocalStore: localFetch)
        let merged = sut.merge(fetchedFromServer: serverFetch)
        XCTAssertEqual(merged.count, 0)
        XCTAssertEqual(sut.addedSet.count, 0)
        XCTAssertEqual(sut.removedSet.count, 0)
    }
    
    func testRecommendedCompaniesMerger_localEmpty_RemoteOne() {
        let localFetch = [Recommendation]()
        let serverFetch: [Recommendation]? = [Recommendation(companyUUID: "0", sortIndex: 0)]
        let sut = RecommendedCompaniesMerger(fetchedFromLocalStore: localFetch)
        let merged = sut.merge(fetchedFromServer: serverFetch)
        XCTAssertEqual(merged.count, 1)
        XCTAssertEqual(sut.addedSet.count, 1)
        XCTAssertEqual(sut.removedSet.count, 0)
    }
    
    func testRecommendedCompaniesMerger_localOne_RemoteNil() {
        let localFetch: [Recommendation] = [Recommendation(companyUUID: "0", sortIndex: 0)]
        let serverFetch: [Recommendation]? = nil
        let sut = RecommendedCompaniesMerger(fetchedFromLocalStore: localFetch)
        let merged = sut.merge(fetchedFromServer: serverFetch)
        XCTAssertEqual(merged.count, 1)
        XCTAssertEqual(sut.addedSet.count, 0)
        XCTAssertEqual(sut.removedSet.count, 0)
    }
    
    func testRecommendedCompaniesMerger_localOne_RemoteEmpty() {
        let localFetch: [Recommendation] = [Recommendation(companyUUID: "0", sortIndex: 0)]
        let serverFetch: [Recommendation]? = []
        let sut = RecommendedCompaniesMerger(fetchedFromLocalStore: localFetch)
        let merged = sut.merge(fetchedFromServer: serverFetch)
        XCTAssertEqual(merged.count, 0)
        XCTAssertEqual(sut.addedSet.count, 0)
        XCTAssertEqual(sut.removedSet.count, 1)
    }
    
    func testRecommendedCompaniesMerger_local_remote_identical() {
        let localFetch: [Recommendation] = [Recommendation(companyUUID: "0", sortIndex: 0)]
        let serverFetch: [Recommendation]? = [Recommendation(companyUUID: "0", sortIndex: 0)]
        let sut = RecommendedCompaniesMerger(fetchedFromLocalStore: localFetch)
        let merged = sut.merge(fetchedFromServer: serverFetch)
        XCTAssertEqual(merged.count, 1)
        XCTAssertEqual(sut.addedSet.count, 0)
        XCTAssertEqual(sut.removedSet.count, 0)
    }
    
    func testRecommendedCompaniesMerger_local_remote_differByUuid() {
        let localFetch: [Recommendation] = [Recommendation(companyUUID: "0", sortIndex: 0)]
        let serverFetch: [Recommendation]? = [Recommendation(companyUUID: "1", sortIndex: 0)]
        let sut = RecommendedCompaniesMerger(fetchedFromLocalStore: localFetch)
        let merged = sut.merge(fetchedFromServer: serverFetch)
        XCTAssertEqual(merged.count, 1)
        XCTAssertEqual(merged.first?.uuid, "1")
        XCTAssertEqual(sut.addedSet.count, 1)
        XCTAssertEqual(sut.removedSet.count, 1)
    }
    
    func testRecommendedCompaniesMerger_nonEmptyIntersection_sameIndex() {
        let localFetch: [Recommendation] =
            [Recommendation(companyUUID: "0", sortIndex: 0),
             Recommendation(companyUUID: "1", sortIndex: 0),
             Recommendation(companyUUID: "2", sortIndex: 0),
             Recommendation(companyUUID: "3", sortIndex: 0),]
        let serverFetch: [Recommendation]? =
            [Recommendation(companyUUID: "2", sortIndex: 0),
             Recommendation(companyUUID: "3", sortIndex: 0),
             Recommendation(companyUUID: "4", sortIndex: 0),
             Recommendation(companyUUID: "5", sortIndex: 0),
             Recommendation(companyUUID: "6", sortIndex: 0)]
        let sut = RecommendedCompaniesMerger(fetchedFromLocalStore: localFetch)
        let merged = sut.merge(fetchedFromServer: serverFetch)
        XCTAssertEqual(merged.count, 5)
        XCTAssertEqual(merged.first?.uuid, "2")
        XCTAssertEqual(sut.addedSet.count, 3)
        XCTAssertEqual(sut.removedSet.count, 2)
    }
    
    func testRecommendedCompaniesMerger_nonEmptyIntersection_differentIndices() {
        let localFetch: [Recommendation] =
            [Recommendation(companyUUID: "0", sortIndex: 0),
             Recommendation(companyUUID: "1", sortIndex: 1),
             Recommendation(companyUUID: "2", sortIndex: 2),
             Recommendation(companyUUID: "3", sortIndex: 3),]
        let serverFetch: [Recommendation]? =
            [Recommendation(companyUUID: "2", sortIndex: 4),
             Recommendation(companyUUID: "3", sortIndex: 5),
             Recommendation(companyUUID: "4", sortIndex: 6),
             Recommendation(companyUUID: "5", sortIndex: 7),
             Recommendation(companyUUID: "6", sortIndex: 8)]
        let sut = RecommendedCompaniesMerger(fetchedFromLocalStore: localFetch)
        let merged = sut.merge(fetchedFromServer: serverFetch)
        XCTAssertEqual(merged.count, 5)
        XCTAssertEqual(merged.first?.uuid, "2")
        XCTAssertEqual(sut.addedSet.count, 3)
        XCTAssertEqual(sut.removedSet.count, 2)
    }
    
    func testRecommendedCompaniesMerger_reset() {
        let localFetch: [Recommendation] =
            [Recommendation(companyUUID: "0", sortIndex: 0),
             Recommendation(companyUUID: "1", sortIndex: 1),
             Recommendation(companyUUID: "2", sortIndex: 2),
             Recommendation(companyUUID: "3", sortIndex: 3),]
        let serverFetch: [Recommendation]? =
            [Recommendation(companyUUID: "2", sortIndex: 4),
             Recommendation(companyUUID: "3", sortIndex: 5),
             Recommendation(companyUUID: "4", sortIndex: 6),
             Recommendation(companyUUID: "5", sortIndex: 7),
             Recommendation(companyUUID: "6", sortIndex: 8)]
        let sut = RecommendedCompaniesMerger(fetchedFromLocalStore: localFetch)
        let merged = sut.merge(fetchedFromServer: serverFetch)
        sut.reset(withFetchFromLocalStore: merged)
        XCTAssertEqual(sut.recommendations.count, 5)
        XCTAssertEqual(sut.addedSet.count, 0)
        XCTAssertEqual(sut.removedSet.count, 0)
        XCTAssertEqual(sut.fetchedFromLocalStore.count, 5)
        XCTAssertNil(sut.fetchedFromServer)
    }
    
    func testRecommendedCompaniesMerger_setFromArray() {
        let array: [Recommendation] =
            [Recommendation(companyUUID: "0", sortIndex: 0),
             Recommendation(companyUUID: "1", sortIndex: 1),
             Recommendation(companyUUID: "2", sortIndex: 2),
             Recommendation(companyUUID: "3", sortIndex: 3),]
        let sut = RecommendedCompaniesMerger(fetchedFromLocalStore: array)
        let set = sut.setFromArray(recommendations: array)
        XCTAssertTrue(set.contains(Recommendation(companyUUID: "0", sortIndex: 0)))
    }
}
