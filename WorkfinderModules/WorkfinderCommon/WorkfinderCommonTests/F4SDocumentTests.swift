import XCTest
@testable import WorkfinderCommon

class F4SGetDocumentJsonTests: XCTestCase {
    func test_initialise() {
        let document = F4SDocument(uuid: "documentUuid", urlString: "urlString", type: F4SUploadableDocumentType.cv, name: "my cv")
        let sut = F4SGetDocumentJson(uuid: "uuid", documents: [document])
        XCTAssertEqual(sut.uuid, "uuid")
        XCTAssertEqual(sut.documents!.count, 1)
        XCTAssertEqual(sut.documents!.first?.uuid, "documentUuid")
    }
}

class F4SPutDocumentJsonTests: XCTestCase {
    func test_initialise() {
        let document = F4SDocument(uuid: "documentUuid", urlString: "urlString", type: F4SUploadableDocumentType.cv, name: "my cv")
        let sut = F4SPutDocumentsJson(documents: [document])
        XCTAssertEqual(sut.documents!.count, 1)
        XCTAssertEqual(sut.documents!.first?.uuid, "documentUuid")
    }
}

class F4SUploadableDocumentTypeTests : XCTestCase {
    func test_name() {
        XCTAssertEqual(F4SUploadableDocumentType.cv.name, "CV")
        XCTAssertEqual(F4SUploadableDocumentType.other.name, "Other")
    }
}

class F4SDocumentTests : XCTestCase {
    func test_initialise_with_name_specified() {
        let sut = F4SDocument(uuid: "test uuid",
                              urlString: "test url",
                              type: F4SUploadableDocumentType.other,
                              name: "test name")
        XCTAssertEqual(sut.uuid!, "test uuid")
        XCTAssertEqual(sut.remoteUrlString, "test url")
        XCTAssertEqual(sut.type, F4SUploadableDocumentType.other)
        XCTAssertEqual(sut.name, "test name")
    }
    
    func test_initialise_with_name_not_specified() {
        let sut = F4SDocument(uuid: "test uuid",
                              urlString: "test url",
                              type: F4SUploadableDocumentType.other,
                              name: nil)
        XCTAssertEqual(sut.uuid!, "test uuid")
        XCTAssertEqual(sut.remoteUrlString, "test url")
        XCTAssertEqual(sut.type, F4SUploadableDocumentType.other)
        XCTAssertEqual(sut.name, F4SUploadableDocumentType.other.name)
    }
    
    func test_isOptionalUrlStringOpenable() {
        XCTAssertFalse(makeSUT().isOptionalUrlStringOpenable(nil))
        XCTAssertFalse(makeSUT().isOptionalUrlStringOpenable("a a"))
        XCTAssertTrue(makeSUT().isOptionalUrlStringOpenable("https://bbc.co.uk"))
    }
    
    func test_isViewable() {
        XCTAssertTrue(makeSUT().isViewableOnUrl)
    }
    
    func test_hasValidRemoteUrl_when_remoteUrlString_is_nil() {
        let sut = makeSUT()
        sut.remoteUrlString = nil
        XCTAssertFalse(sut.hasValidRemoteUrl)
        XCTAssertNil(sut.remoteUrl)
    }
    
    func test_hasValidRemoteUrl_when_valid() {
        let sut = makeSUT()
        sut.remoteUrlString = "valid"
        XCTAssertTrue(sut.hasValidRemoteUrl)
        XCTAssertNotNil(sut.remoteUrl)
    }
    
    func test_hasValidRemoteUrl_when_invalid() {
        let sut = makeSUT()
        sut.remoteUrlString = "not valid"
        XCTAssertFalse(sut.hasValidRemoteUrl)
        XCTAssertNil(sut.remoteUrl)
    }
    
    func test_isReadyForUpload_when_already_uploaded() {
        let sut = makeSUT()
        sut.isUploaded = true
        XCTAssertFalse(sut.isReadyForUpload)
    }
    
    func test_isReadyForUpload_url_is_valid_data_is_nil() {
        let sut = makeSUT()
        sut.remoteUrlString = "valid"
        XCTAssertTrue(sut.isReadyForUpload)
    }
    
    func test_isReadyForUpload_url_cannot_be_opened_data_is_nil() {
        let sut = makeSUT()
        sut.canOpenURL = { _ in return false }
        sut.remoteUrlString = "valid"
        XCTAssertFalse(sut.isReadyForUpload)
    }
    
    func test_isReadyForUpload_url_is_not_valid_but_data_is() {
        let sut = makeSUT()
        sut.remoteUrlString = "not valid"
        sut.data = "data".data(using: String.Encoding.utf8)
        XCTAssertTrue(sut.isReadyForUpload)
    }
    
    func test_defaultName() {
        let sut = makeSUT()
        sut.name = nil
        XCTAssertNotNil(sut.defaultName)
    }
    
    func makeSUT() -> F4SDocument {
        let sut = F4SDocument(uuid: "test uuid",
                              urlString: "testUrl",
                              type: F4SUploadableDocumentType.other,
                              name: "test name")
        sut.canOpenURL = { url in return true }
        return sut
    }
}
