
import XCTest
import WorkfinderCommon

class AssociationJsonTests: XCTestCase {
    
    func test() {
        let dataString = """
        {
            \"uuid\":\"44c78fad-9f7f-43f1-addf-25c2bf3fbb52\",
            \"host\":\"5eff77e5-0969-41f5-a0c6-037ada127ad4\",
            \"location\":\"6a77d1b4-0494-4c93-ac0d-73c2bfdb0f07\",
            \"title\":\"Founder & Chief Executive Officer\",
            \"started\":null,
            \"stopped\":null,
            \"description\":\"\"
        }
        """
        let data = dataString.data(using: .utf8)!
        let association = try! JSONDecoder().decode(AssociationJson.self, from: data) as AssociationJson
        XCTAssertEqual(association.uuid, "44c78fad-9f7f-43f1-addf-25c2bf3fbb52")
        XCTAssertEqual(association.hostUuid, "5eff77e5-0969-41f5-a0c6-037ada127ad4")
        XCTAssertEqual(association.locationUuid, "6a77d1b4-0494-4c93-ac0d-73c2bfdb0f07")
        XCTAssertEqual(association.title, "Founder & Chief Executive Officer")
        XCTAssertEqual(association.description, "")
    }
}
