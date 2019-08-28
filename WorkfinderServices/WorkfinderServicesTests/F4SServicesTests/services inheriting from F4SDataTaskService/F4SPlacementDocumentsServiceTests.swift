import XCTest
import WorkfinderCommon
import WorkfinderNetworking
@testable import WorkfinderServices

class F4SPlacementDocumentsServiceTests : XCTestCase {
    
    func test_initialise() {
        let placementUuid = "placementUuid"
        let sut = F4SPlacementDocumentsService(placementUuid: placementUuid)
        XCTAssertEqual(sut.apiName, "placement/\(placementUuid)/documents")
    }
    
    func test_getDocuments() {
        let placementUuid = "placementUuid"
        let sut = F4SPlacementDocumentsService(placementUuid: placementUuid)
        let expectedValue = F4SGetDocumentJson(uuid: "uuid", documents: [F4SDocument(uuid: "documentUuid", urlString: "url/url", type: F4SUploadableDocumentType.cv, name: "my cv")])
        let requiredResult = F4SNetworkResult.success(expectedValue)
        sut.networkTaskfactory = MockF4SNetworkTaskFactory(requiredSuccessResult: requiredResult)
        let expectation = XCTestExpectation(description: "")
        sut.getDocuments { (result) in
            switch result {
            case .error(_):
                XCTFail("The test was designed to return a success result")
            case .success(let documents):
                XCTAssertEqual(documents.documents!.first!.uuid, "documentUuid")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
//    func test_putDocuments() {
//        let placementUuid = "placementUuid"
//        let sut = F4SPlacementDocumentsService(placementUuid: placementUuid)
//        let document = F4SDocument(uuid: "docUuid", urlString: "url/url", type: F4SUploadableDocumentType.cv, name: "my cv")
//        let expectation  = XCTestExpectation(description: "")
//        let requiredResult = F4SNetworkDataResult.success(Data())
//        sut.networkTaskfactory = MockF4SNetworkTaskFactory(requiredSuccessResult:
//            requiredResult)
//        sut.putDocuments(documents: [document], completion: <#T##((F4SNetworkDataResult) -> Void)##((F4SNetworkDataResult) -> Void)##(F4SNetworkDataResult) -> Void#>)
//        
//        sut.apply(with: applyJson) { (result) in
//            switch result {
//            case .error(_):
//                XCTFail("This test was designed to return a success result")
//            case .success(let placement):
//                expectation.fulfill()
//                XCTAssertEqual(placement.userUuid,"userUuid")
//            }
//        }
//        wait(for: [expectation], timeout: 1)
//    }
}
