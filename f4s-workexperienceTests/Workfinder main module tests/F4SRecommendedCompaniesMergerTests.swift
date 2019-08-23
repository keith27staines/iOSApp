import XCTest
import WorkfinderCommon
@testable import f4s_workexperience

class F4SRecommendedCompaniesMergerTests: XCTestCase {

    func testRecommendedCompaniesMerger_localEmpty_RemoteNil() {
        let localFetch = [F4SRecommendation]()
        let serverFetch: [F4SRecommendation]? = nil
        let sut = RecommendedCompaniesMerger(fetchedFromLocalStore: localFetch)
        let merged = sut.merge(fetchedFromServer: serverFetch)
        XCTAssertEqual(merged.count, 0)
        XCTAssertEqual(sut.addedSet.count, 0)
        XCTAssertEqual(sut.removedSet.count, 0)
    }
    
    func testRecommendedCompaniesMerger_localEmpty_RemoteOne() {
        let localFetch = [F4SRecommendation]()
        let serverFetch: [F4SRecommendation]? = [F4SRecommendation(companyUUID: "0", sortIndex: 0)]
        let sut = RecommendedCompaniesMerger(fetchedFromLocalStore: localFetch)
        let merged = sut.merge(fetchedFromServer: serverFetch)
        XCTAssertEqual(merged.count, 1)
        XCTAssertEqual(sut.addedSet.count, 1)
        XCTAssertEqual(sut.removedSet.count, 0)
    }
    
    func testRecommendedCompaniesMerger_localOne_RemoteNil() {
        let localFetch: [F4SRecommendation] = [F4SRecommendation(companyUUID: "0", sortIndex: 0)]
        let serverFetch: [F4SRecommendation]? = nil
        let sut = RecommendedCompaniesMerger(fetchedFromLocalStore: localFetch)
        let merged = sut.merge(fetchedFromServer: serverFetch)
        XCTAssertEqual(merged.count, 1)
        XCTAssertEqual(sut.addedSet.count, 0)
        XCTAssertEqual(sut.removedSet.count, 0)
    }
    
    func testRecommendedCompaniesMerger_localOne_RemoteEmpty() {
        let localFetch: [F4SRecommendation] = [F4SRecommendation(companyUUID: "0", sortIndex: 0)]
        let serverFetch: [F4SRecommendation]? = []
        let sut = RecommendedCompaniesMerger(fetchedFromLocalStore: localFetch)
        let merged = sut.merge(fetchedFromServer: serverFetch)
        XCTAssertEqual(merged.count, 0)
        XCTAssertEqual(sut.addedSet.count, 0)
        XCTAssertEqual(sut.removedSet.count, 1)
    }
    
    func testRecommendedCompaniesMerger_local_remote_identical() {
        let localFetch: [F4SRecommendation] = [F4SRecommendation(companyUUID: "0", sortIndex: 0)]
        let serverFetch: [F4SRecommendation]? = [F4SRecommendation(companyUUID: "0", sortIndex: 0)]
        let sut = RecommendedCompaniesMerger(fetchedFromLocalStore: localFetch)
        let merged = sut.merge(fetchedFromServer: serverFetch)
        XCTAssertEqual(merged.count, 1)
        XCTAssertEqual(sut.addedSet.count, 0)
        XCTAssertEqual(sut.removedSet.count, 0)
    }
    
    func testRecommendedCompaniesMerger_local_remote_differByUuid() {
        let localFetch: [F4SRecommendation] = [F4SRecommendation(companyUUID: "0", sortIndex: 0)]
        let serverFetch: [F4SRecommendation]? = [F4SRecommendation(companyUUID: "1", sortIndex: 0)]
        let sut = RecommendedCompaniesMerger(fetchedFromLocalStore: localFetch)
        let merged = sut.merge(fetchedFromServer: serverFetch)
        XCTAssertEqual(merged.count, 1)
        XCTAssertEqual(merged.first?.uuid, "1")
        XCTAssertEqual(sut.addedSet.count, 1)
        XCTAssertEqual(sut.removedSet.count, 1)
    }
    
    func testRecommendedCompaniesMerger_nonEmptyIntersection_sameIndex() {
        let localFetch: [F4SRecommendation] =
            [F4SRecommendation(companyUUID: "0", sortIndex: 0),
             F4SRecommendation(companyUUID: "1", sortIndex: 0),
             F4SRecommendation(companyUUID: "2", sortIndex: 0),
             F4SRecommendation(companyUUID: "3", sortIndex: 0),]
        let serverFetch: [F4SRecommendation]? =
            [F4SRecommendation(companyUUID: "2", sortIndex: 0),
             F4SRecommendation(companyUUID: "3", sortIndex: 0),
             F4SRecommendation(companyUUID: "4", sortIndex: 0),
             F4SRecommendation(companyUUID: "5", sortIndex: 0),
             F4SRecommendation(companyUUID: "6", sortIndex: 0)]
        let sut = RecommendedCompaniesMerger(fetchedFromLocalStore: localFetch)
        let merged = sut.merge(fetchedFromServer: serverFetch)
        XCTAssertEqual(merged.count, 5)
        XCTAssertEqual(merged.first?.uuid, "2")
        XCTAssertEqual(sut.addedSet.count, 3)
        XCTAssertEqual(sut.removedSet.count, 2)
    }
    
    func testRecommendedCompaniesMerger_nonEmptyIntersection_differentIndices() {
        let localFetch: [F4SRecommendation] =
            [F4SRecommendation(companyUUID: "0", sortIndex: 0),
             F4SRecommendation(companyUUID: "1", sortIndex: 1),
             F4SRecommendation(companyUUID: "2", sortIndex: 2),
             F4SRecommendation(companyUUID: "3", sortIndex: 3),]
        let serverFetch: [F4SRecommendation]? =
            [F4SRecommendation(companyUUID: "2", sortIndex: 4),
             F4SRecommendation(companyUUID: "3", sortIndex: 5),
             F4SRecommendation(companyUUID: "4", sortIndex: 6),
             F4SRecommendation(companyUUID: "5", sortIndex: 7),
             F4SRecommendation(companyUUID: "6", sortIndex: 8)]
        let sut = RecommendedCompaniesMerger(fetchedFromLocalStore: localFetch)
        let merged = sut.merge(fetchedFromServer: serverFetch)
        XCTAssertEqual(merged.count, 5)
        XCTAssertEqual(merged.first?.uuid, "2")
        XCTAssertEqual(sut.addedSet.count, 3)
        XCTAssertEqual(sut.removedSet.count, 2)
    }
    
    func testRecommendedCompaniesMerger_reset() {
        let localFetch: [F4SRecommendation] =
            [F4SRecommendation(companyUUID: "0", sortIndex: 0),
             F4SRecommendation(companyUUID: "1", sortIndex: 1),
             F4SRecommendation(companyUUID: "2", sortIndex: 2),
             F4SRecommendation(companyUUID: "3", sortIndex: 3),]
        let serverFetch: [F4SRecommendation]? =
            [F4SRecommendation(companyUUID: "2", sortIndex: 4),
             F4SRecommendation(companyUUID: "3", sortIndex: 5),
             F4SRecommendation(companyUUID: "4", sortIndex: 6),
             F4SRecommendation(companyUUID: "5", sortIndex: 7),
             F4SRecommendation(companyUUID: "6", sortIndex: 8)]
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
        let array: [F4SRecommendation] =
            [F4SRecommendation(companyUUID: "0", sortIndex: 0),
             F4SRecommendation(companyUUID: "1", sortIndex: 1),
             F4SRecommendation(companyUUID: "2", sortIndex: 2),
             F4SRecommendation(companyUUID: "3", sortIndex: 3),]
        let sut = RecommendedCompaniesMerger(fetchedFromLocalStore: array)
        let set = sut.setFromArray(recommendations: array)
        XCTAssertTrue(set.contains(F4SRecommendation(companyUUID: "0", sortIndex: 0)))
    }
}
