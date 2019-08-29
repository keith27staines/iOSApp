import XCTest
import WorkfinderCommon
import WorkfinderNetworking
@testable import WorkfinderServices

class F4SCompanyDocumentServiceTests: XCTestCase {

    func test_initialise() {
        let sut = F4SCompanyDocumentService()
        XCTAssertEqual(sut.apiName, "company")
    }
    
    func test_getDocuments() {
        let sut = F4SCompanyDocumentService()
        let expectedDocument = F4SCompanyDocument(uuid: "documentUuid", name: "document name", status: F4SCompanyDocument.State.requested, docType: "document type")
        let expectedDocuments = F4SGetCompanyDocuments(companyUuid: "companyUuid", documents: [expectedDocument], possibleDocumentTypes: nil)
        let expectedResult = F4SNetworkResult.success(expectedDocuments)
        sut.networkTaskfactory = MockF4SNetworkTaskFactory(requiredSuccessResult: expectedResult)
        let expectation = XCTestExpectation(description: "")
        sut.getDocuments(companyUuid: "companyUuid") { (result) in
            switch result {
            case .error(_):
                XCTFail("This test was designed to return a success result")
            case .success(let documents):
                XCTAssertEqual(documents.companyUuid, "companyUuid")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(sut.url.absoluteString, "/v2/company/companyUuid/documents")
        XCTAssertEqual((sut.task as! MockNetworkTask<F4SGetCompanyDocuments>).verb!, F4SHttpRequestVerb.get)
    }
    
    func test_requestDocuments() {
        let sut = F4SCompanyDocumentService()
        let document = F4SCompanyDocument(uuid: "documentUuid", name: "document name", status: F4SCompanyDocument.State.requested, docType: "document type")
        let documents = [document]
        let expectedResult = F4SNetworkResult.success(F4SJSONBoolValue(value: true))
        sut.networkTaskfactory = MockF4SNetworkTaskFactory(requiredSuccessResult: expectedResult)
        let expectation = XCTestExpectation(description: "")
        sut.requestDocuments(companyUuid: "companyUuid", documents: documents) { (result) in
            switch result {
            case .error(_):
                XCTFail("This test was designed to return a success result")
            case .success(let result):
                XCTAssertTrue(result.value)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

}
