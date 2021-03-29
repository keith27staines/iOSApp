//
//  PostcodeTests.swift
//  WorkfinderCandidateProfileTests
//
//  Created by Keith Staines on 24/03/2021.
//

import XCTest
@testable import WorkfinderCandidateProfile

class PostcodeTests: XCTestCase {

        func test_good_postcode_no_spaces() {
            let service = ValidatePostcodeService()
            let expectation = XCTestExpectation()
            service.validatePostcode("HU89AG") { (result) in
                switch result {
                case .success(let isValid):
                    XCTAssertTrue(isValid)
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                }
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 1000.0)
        }
        
        func test_good_postcode_with_space() {
            let service = ValidatePostcodeService()
            let expectation = XCTestExpectation()
            service.validatePostcode("HU8 9AG") { (result) in
                switch result {
                case .success(let isValid):
                    XCTAssertTrue(isValid)
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                }
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 1000.0)
        }
        
        func test_invalidate_postcode() {
            let service = ValidatePostcodeService()
            let expectation = XCTestExpectation()
            service.validatePostcode("8U8 9AG") { (result) in
                switch result {
                case .success(_):
                    XCTFail("The postcode was not recognised as invalid")
                case .failure(let error):
                    XCTAssertTrue(error.title == "Postcode not valid")
                }
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 1000.0)
        }
        
        func test_valid_postcode_no_addresses() {
            let service = ValidatePostcodeService()
            let expectation = XCTestExpectation()
            service.validatePostcode("XX4 04X") { (result) in
                switch result {
                case .success(_):
                    XCTFail("The postcode was not recognised as having no addresses")
                case .failure(let error):
                    XCTAssertTrue(error.title == "No addresses found")
                }
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 1000.0)
        }
        
        func test_valid_postcode_bad_apiKey() {
            let service = ValidatePostcodeService()
            let expectation = XCTestExpectation()
            service.validatePostcode("XX4 01X") { (result) in
                switch result {
                case .success(_):
                    XCTFail("The postcode was not recognised as having no addresses")
                case .failure(let error):
                    XCTAssertTrue(error.title == "Unable to validate postcode")
                }
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 1000.0)
        }
        
        func test_regex() {
            XCTAssertTrue("HU8 9AG".isUKPostcode())
            XCTAssertFalse("HU89A".isUKPostcode())
            XCTAssertTrue("TD9 0TU".isUKPostcode())
        }

    }

