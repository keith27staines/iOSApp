//
//  ApplicationLetterModelTests.swift
//  WorkfinderApplyUseCaseTests
//
//  Created by Keith Dev on 25/03/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import XCTest
import WorkfinderCommon

@testable import WorkfinderApplyUseCase

class ApplicationLetterModelTests: XCTestCase {
    
    func test_ApplicationLetterModel_Init() {
        let expectation = XCTestExpectation(description: "letter model")
        let mockTemplateService = MockF4STemplateService()
        let testDelegate = TestLetterModelDelegate()
        testDelegate.reportRendered = { text, allFieldsFilled in
            XCTAssertTrue(text.string.starts(with: "Dear Sir"))
            expectation.fulfill()
        }
        let mockStore = MockLocalStore()
        let blanksModel = ApplicationLetterTemplateBlanksModel(store: mockStore)
        let sut = ApplicationLetterModel(
            companyName: "MegaCorp",
            templateService: mockTemplateService,
            delegate: testDelegate,
            blanksModel: blanksModel)
        sut.render()
        wait(for: [expectation], timeout: 1)
    }
}

class MockWEXPlacementService : WEXPlacementServiceProtocol {
    func createPlacement(with json: WEXCreatePlacementJson, completion: @escaping (WEXResult<WEXPlacementJson, WEXError>) -> Void) {
        
    }
    
    func patchPlacement(uuid: F4SUUID, with json: WEXPlacementJson, completion: @escaping (WEXResult<WEXPlacementJson, WEXError>) -> Void) {
        
    }
}

class TestLetterModelDelegate : ApplicationLetterModelDelegate{
    
    var reportBusyStateSet: ((Bool) -> Void ) = { isBusy in }
    var reportProcessingError: ((Error) -> Void) = { error in }
    var reportRendered: ((NSAttributedString, Bool) -> Void) = { text, allFieldsFilled in }
    
    func modelBusyState(_ model: ApplicationLetterModelProtocol, isBusy: Bool) {
        reportBusyStateSet(isBusy)
    }
    
    func applicationLetterModel(_ model: ApplicationLetterModelProtocol, stoppedProcessingWithError error: Error) {
        reportProcessingError(error)
    }
    
    func applicationLetterModel(_ model: ApplicationLetterModelProtocol, renderedTemplateToString: NSAttributedString, allFieldsFilled: Bool) {
        reportRendered(renderedTemplateToString, allFieldsFilled)
    }
    
    func applicationLetterModel(_ model: ApplicationLetterModelProtocol, failedToSubmitLetter error: WEXError, retry: (() -> Void)?) {
        
    }
}

class MockF4STemplateService : F4STemplateServiceProtocol {
    var successResult: F4SNetworkResult<[F4STemplate]> = {
        let template = makeTemplate()
        return F4SNetworkResult.success([template])
    }()
    
    func getTemplates(completion: @escaping (F4SNetworkResult<[F4STemplate]>) -> Void) {
        completion(successResult)
    }
}
