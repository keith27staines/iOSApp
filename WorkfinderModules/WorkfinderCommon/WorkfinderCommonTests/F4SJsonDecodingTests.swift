//
//  F4SJsonDecodingTests.swift
//  f4s-workexperienceTests
//
//  Created by Keith Dev on 06/07/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import XCTest
@testable import WorkfinderCommon

class F4SJsonDecodingTests: XCTestCase {
    
    struct Json: Codable {
        var value: Int
    }
    
    var json: Json!
    var successData: Data!
    var errorData: Data!
    var successDataResult: F4SNetworkDataResult!
    var errorDataResult: F4SNetworkDataResult!
    var networkError: F4SNetworkError!
    var attempting: String!
    
    override func setUp() {
        super.setUp()
        attempting = "doing a test"
        networkError = F4SNetworkDataErrorType.unknownError(nil).error(attempting: attempting)
        json = Json(value: 1234)
        successData = try! JSONEncoder().encode(json)
        errorData = Data()
        successDataResult = F4SNetworkDataResult.success(successData)
        errorDataResult = F4SNetworkDataResult.error(networkError)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        attempting = nil
        networkError = nil
        json = nil
        successData = nil
        successDataResult = nil
        errorDataResult = nil
    }
    
    func testDecodingValidData() {
        JSONDecoder().decode(data: successData, intoType: Json.self, attempting: attempting) { (networkResult) in
            switch networkResult {
            case .error(let error):
                XCTAssertTrue(false, "Decoding good data yielded error \(error)")
            case .success(let jsonResult):
                XCTAssertEqual(jsonResult.value, json.value)
            }
        }
    }
    
    func testDecodingInvalidData() {
        JSONDecoder().decode(data: errorData, intoType: Json.self, attempting: attempting) { (networkResult) in
            switch networkResult {
            case .error(let error):
                XCTAssertEqual(error.code, F4SNetworkDataErrorType.deserialization(errorData).error(attempting: attempting).code)
            case .success(_):
                XCTAssertTrue(false, "Decoding empty data succeeded but was expected to error")
            }
        }
    }
    
    func testDecodingNilData() {
        JSONDecoder().decode(data: nil, intoType: Json.self, attempting: attempting) { (networkResult) in
            switch networkResult {
            case .error(let error):
                XCTAssertEqual(error.code, F4SNetworkDataErrorType.noData.error(attempting: attempting).code)
            case .success(_):
                XCTAssertTrue(false, "Decoding empty data succeeded but was expected to error")
            }
        }
    }
    
    func testDecodeNetworkDataResultHoldingValidData() {
        JSONDecoder().decode(dataResult: successDataResult, intoType: Json.self, attempting: attempting) { (networkResult) in
            switch networkResult {
            case .error(let error):
                XCTAssertTrue(false, "Decoding success result yielded error \(error)")
            case .success(let jsonResult):
                XCTAssertEqual(jsonResult.value, json.value)
            }
        }
    }
    
    func testDecodeNetworkDataResultHoldingError() {
        JSONDecoder().decode(dataResult: errorDataResult, intoType: Json.self, attempting: attempting) { (networkResult) in
            switch networkResult {
            case .error(let error):
                XCTAssertEqual(error.code, networkError.code)
            case .success(_):
                XCTAssertTrue(false, "A non-error result was not expected")
            }
        }
    }
}
