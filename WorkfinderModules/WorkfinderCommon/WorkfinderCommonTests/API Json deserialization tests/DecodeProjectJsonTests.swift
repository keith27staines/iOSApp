
import XCTest
@testable import WorkfinderCommon

class ProjectJsonTests: XCTestCase {

    let jsonString = """
    {\"uuid\": \"88e20661-814b-4d1f-b62f-37f7b9c5be0e\",
    \"type\": \"db0ffacd-c38c-4cb8-9476-548017aa3ede\",
    \"is_paid\": true,
    \"candidate_quantity\": \"3\",
    \"is_remote\": false,
    \"duration\": \"abcdef\"}
    """
    
    func test_decode() throws {
        let data = try XCTUnwrap(jsonString.data(using: .utf8))
        let p = try JSONDecoder().decode(ProjectJson.self, from: data)
        XCTAssertEqual(p, makeSUT())
    }
    
    public func test_encode_decode() throws {
        let p = makeSUT()
        let data = try JSONEncoder().encode(p)
        let q = try JSONDecoder().decode(ProjectJson.self, from: data)
        XCTAssertEqual(p, q)
    }
    
    func makeSUT() -> ProjectJson {
        var project = ProjectJson()
        project.uuid = "88e20661-814b-4d1f-b62f-37f7b9c5be0e"
        project.type = "db0ffacd-c38c-4cb8-9476-548017aa3ede"
        project.association = nil
        project.isPaid = true
        project.candidateQuantity = "3"
        project.isRemote = false
        project.duration = "abcdef"
        return project
    }
}
