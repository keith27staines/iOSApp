//
//  F4SCompanyDocumentsTests.swift
//  WorkfinderCommonTests
//
//  Created by Keith Dev on 03/02/2020.
//  Copyright © 2020 Founders4Schools. All rights reserved.
//

import XCTest
@testable import WorkfinderCommon

class F4SGetCompanyDocumentsTests: XCTestCase {
    
    func test_initialise() {
        let documents = [F4SCompanyDocument(documentType: "Type1")]
        let possibleDocumentTypes = ["Type1"]
        let sut = F4SGetCompanyDocuments(
            companyUuid: "companyUuid",
            documents: documents,
            possibleDocumentTypes: possibleDocumentTypes)
        XCTAssertEqual(sut.companyUuid, "companyUuid")
        XCTAssertEqual(sut.documents?.first?.docType, "Type1")
        XCTAssertEqual(sut.possibleDocumentTypes, possibleDocumentTypes)
    }
    
}

class F4SCompanyDocumentTests: XCTestCase {

    func makeSut() -> F4SCompanyDocument {
        return F4SCompanyDocument(uuid: "uuid", name: "name", status: .available, docType: "SGC", requestedCount: 17, urlString: "urlString")
        
    }
    
    func test_init_from_docType() {
        let sut = F4SCompanyDocument(documentType: "Type1")
        XCTAssertEqual(sut.docType, "Type1")
        XCTAssertTrue(sut.state == .unrequested)
        XCTAssertEqual(sut.name, sut.docType)
    }
    
    func test_init_full_detail() {
        let sut = makeSut()
        XCTAssertEqual(sut.uuid, "uuid")
        XCTAssertEqual(sut.name, "name")
        XCTAssertEqual(sut.state, .available)
        XCTAssertEqual(sut.docType, "SGC")
        XCTAssertEqual(sut.requestedCount, 17)
        XCTAssertEqual(sut.urlString, "urlString")
    }
    
    func test_isViewable_when_viewable() {
        var sut = makeSut()
        sut.state = .available
        sut.urlString = "something/somewhere"
        XCTAssertTrue(sut.isViewable)
    }
    
    func test_isViewable_when_no_url() {
        var sut = makeSut()
        sut.state = .available
        sut.urlString = nil
        XCTAssertFalse(sut.isViewable)
    }
    
    func test_isViewable_when_unavailable() {
        var sut = makeSut()
        sut.state = .unavailable
        sut.urlString = "something/somewhere"
        XCTAssertFalse(sut.isViewable)
    }
    
    func test_isRequestable_when_state_is_unreqeusted() {
        var sut = makeSut()
        sut.state = .unrequested
        XCTAssertTrue(sut.isRequestable)
    }
    
    func test_isRequestable_when_state_is_requested() {
        var sut = makeSut()
        sut.state = .requested
        XCTAssertTrue(sut.isRequestable)
    }
    
    func test_isRequestable_when_state_is_available() {
        var sut = makeSut()
        sut.state = .available
        XCTAssertFalse(sut.isRequestable)
    }
    
    func test_isRequestable_when_state_is_unavailable() {
        var sut = makeSut()
        sut.state = .unavailable
        XCTAssertFalse(sut.isRequestable)
    }
    
    func test_providedNameOrDefaultName_with_providedName() {
        var sut = F4SCompanyDocument(documentType: "Type1")
        sut.name = "name"
        XCTAssertEqual(sut.providedNameOrDefaultName, "name")
    }
    
    func test_providedNameOrDefaultName_without_providedName() {
        let sut = F4SCompanyDocument(documentType: "Type1")
        XCTAssertEqual(sut.providedNameOrDefaultName, "Type1")
    }
    
    func test_static_defaultNameForType() {
        XCTAssertEqual(F4SCompanyDocument.defaultNameForType(type: "ELC"), "Employer's liability certificate")
        XCTAssertEqual(F4SCompanyDocument.defaultNameForType(type: "SGC"), "Safeguarding certificate")
        XCTAssertEqual(F4SCompanyDocument.defaultNameForType(type: "other12345"), "other12345")
        XCTAssertEqual(F4SCompanyDocument.defaultNameForType(type: "ELC"), "Employer's liability certificate")
    }

}
