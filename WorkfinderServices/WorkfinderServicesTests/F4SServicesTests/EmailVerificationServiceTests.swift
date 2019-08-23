//
//  EmailVerificationServiceTests.swift
//  WorkfinderServicesTests
//
//  Created by Keith Dev on 23/08/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import XCTest
import WorkfinderCommon
@testable import WorkfinderServices

class EmailVerificationServiceTests: XCTestCase {
    let email = "email"
    let clientId = "clientId"
    func test_initialise() {
        let sut = EmailVerificationService(email: email, clientId: clientId)
        XCTAssertEqual(sut.email, email)
        XCTAssertEqual(sut.startClientId, clientId)
    }
    
    func test_cancel() {
        let sut = EmailVerificationService(email: email, clientId: clientId)
        let mockTask = MockTask(completion: { (data, response, error) in })
        sut.task = mockTask
        sut.cancel()
        XCTAssertTrue(mockTask.cancelled)
    }
    
    
    func test_prepareRequest() {
        let sut = EmailVerificationService(email: email, clientId: clientId)
        let data = Data()
        let request = sut.prepareRequest(urlString: "url/url", method: "POST", bodyData: data)
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.url, URL(string: "url/url")!)
    }
    
    func test_codeValidationError() {
        XCTAssertNil(validationErrorFromCode(200))
        XCTAssertTrue(validationErrorFromCode(401)!.localizedDescription == EmailVerificationService.CodeValidationError.codeEmailCombinationNotValid.localizedDescription)
        XCTAssertTrue(validationErrorFromCode(456)!.localizedDescription == EmailVerificationService.CodeValidationError.networkError(456).localizedDescription)
    }
    
    func validationErrorFromCode(_ code: Int) -> EmailVerificationService.CodeValidationError? {
        return EmailVerificationService.CodeValidationError.codeValidationError(from: code)
    }
    
    func test_submissionError() {
        XCTAssertNil(submissionErrorFromCode(200))
        XCTAssertEqual(submissionErrorFromCode(400)?.localizedDescription,  EmailVerificationService.EmailSubmissionError.serversideEmailFormatCheckFailed.localizedDescription)
        XCTAssertEqual(submissionErrorFromCode(445)?.localizedDescription,  EmailVerificationService.EmailSubmissionError.networkError(456).localizedDescription)
    }
    
    func submissionErrorFromCode(_ code: Int) -> EmailVerificationService.EmailSubmissionError? {
        return EmailVerificationService.EmailSubmissionError.emailSubmissionError(from: code)
    }
}
