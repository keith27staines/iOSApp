import XCTest
import WorkfinderCommon

class F4SRoleJsonTests: XCTestCase {

    func test_initialise() {
        let sut = F4SRoleJson(uuid: "uuid", name: "name", description: "description")
        XCTAssertEqual(sut.description, "description")
        XCTAssertEqual(sut.name, "name")
        XCTAssertEqual(sut.uuid, "uuid")
    }
}
