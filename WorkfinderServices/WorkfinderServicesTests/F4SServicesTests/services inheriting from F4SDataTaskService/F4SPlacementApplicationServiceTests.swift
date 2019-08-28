import XCTest
@testable import WorkfinderServices

class F4SPlacementApplicationServiceTests: XCTestCase {

    func test_initialise() {
        let sut = F4SPlacementApplicationService()
        XCTAssertEqual(sut.apiName, "placement")
    }
    
    

}
