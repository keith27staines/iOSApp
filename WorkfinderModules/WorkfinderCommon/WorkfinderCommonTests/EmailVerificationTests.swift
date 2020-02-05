//
//  EmailVerificationTests.swift
//  WorkfinderCommonTests
//
//  Created by Keith Dev on 04/02/2020.
//  Copyright © 2020 Founders4Schools. All rights reserved.
//

import XCTest
@testable import WorkfinderCommon

class CodeValidationErrorTests: XCTestCase {

    func test_static_codeValidationError_when_success() {
        XCTAssertNil(CodeValidationError.codeValidationError(from: 200))
    }
    
    func test_static_codeValidationError_when_400() {
        switch CodeValidationError.codeValidationError(from: 401) {
        case .codeEmailCombinationNotValid: break // epxected result
        default:
            XCTFail("wrong error returned")
        }
    }
    
    func test_static_codeValidationError_when_other_error() {
        let code = 456
        switch CodeValidationError.codeValidationError(from: code) {
        case .networkError(let returnedCode):
            XCTAssertEqual(returnedCode, code)
        default:
            XCTFail("wrong error returned")
        }
    }
}

class EmailSubmissionErrorTests: XCTestCase {
    
    func test_static_emailSubmissionError_is_nil_from_success() {
        XCTAssertNil(EmailSubmissionError.emailSubmissionError(from: 200))
    }
    
    func test_static_emailSubmissionError_from_400() {
        let error = EmailSubmissionError.emailSubmissionError(from: 400)!
        switch error {
        case .serversideEmailFormatCheckFailed: break // expected result
        default:
            XCTFail("wrong error")
        }
    }
    
    func test_static_emailSubmissionError_from_other() {
        let error = EmailSubmissionError.emailSubmissionError(from: 456)!
        switch error {
        case .networkError(let returnStatus):
            XCTAssertEqual(returnStatus, 456)
        default:
            XCTFail("wrong error")
        }
    }
    
}
