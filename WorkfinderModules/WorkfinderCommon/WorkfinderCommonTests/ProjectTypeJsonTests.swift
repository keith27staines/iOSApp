
fileprivate let jsonString =
"""
{
    \"uuid\": \"uuid\",
    \"name\": \"name\",
    \"description\": \"description\",
    \"read_more_url\": \"readMoreUrl\",
    \"icon\": \"icon\",
    \"candidate_activities\": [
        \"activity1\",
        \"activity2\"
    ],
    \"skills_acquired\": [
        \"skill1\",
        \"skill2\"
    ],
    \"about_candidate\": \"aboutCandidate\"
}
"""

import XCTest
@testable import WorkfinderCommon

class ProjectTypeJsonTests: XCTestCase {
    
    func test_decode() throws {
        let data = try XCTUnwrap(jsonString.data(using: .utf8))
        let p = try JSONDecoder().decode(ProjectTypeJson.self, from: data)
        XCTAssertEqual(p, makeSUT())
    }
    
    public func test_encode_decode() throws {
        let p = makeSUT()
        let data = try JSONEncoder().encode(p)
        let q = try JSONDecoder().decode(ProjectTypeJson.self, from: data)
        XCTAssertEqual(p, q)
    }
    
    func makeSUT() -> ProjectTypeJson {
        return ProjectTypeJson(
            uuid: "uuid",
            name: "name",
            description: "description",
            readMoreUrl: "readMoreUrl",
            icon: "icon",
            candidateActivities: ["activity1", "activity2"],
            skillsAcquired: ["skill1", "skill2"],
            aboutCandidate: "aboutCandidate")
    }
}
