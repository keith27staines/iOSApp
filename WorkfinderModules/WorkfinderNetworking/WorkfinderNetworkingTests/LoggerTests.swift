//
//  LoggerTests.swift
//  WorkfinderNetworkingTests
//
//  Created by Keith Dev on 24/07/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import XCTest
import WorkfinderCommon
@testable import WorkfinderNetworking

class LoggerTests: XCTestCase {
    
    let testURL = URL(string: "https://someserver.com")!
    
    func test_injected_log_is_being_used() {
        let log = MockLog()
        log.identity(userId: "Test identity")
        let sut = Logger(log: log)
        XCTAssertEqual((sut.log as? MockLog)!.lastIdentity, "Test identity")
    }
    
    func test_convertTaskFailureToError() {
        let sut = Logger(log: MockLog())
        let nsError = sut.taskFailureToError(code: 12345, text: "Bad stuff happened")
        XCTAssertEqual(nsError.domain, "iOS Workfinder Networking")
        XCTAssertEqual(nsError.userInfo["reason"] as! String, "Bad stuff happened")
    }
    
    func test_logDataTaskSuccess() {
        let log = MockLog()
        let sut = Logger(log: log)
        var request = URLRequest(url: testURL)
        request.httpBody = "RequestData".data(using: String.Encoding.utf8)!
        request.allHTTPHeaderFields = ["headerField1":"headerField1"]
        let response = HTTPURLResponse(url: testURL, statusCode: 200, httpVersion: "httpVersion", headerFields: ["header1":"header1"])!
        let responseData = "ResponseData".data(using: String.Encoding.utf8)!
        sut.logDataTaskSuccess(request: request, response: response, responseData: responseData)
        let expectedLogText = """



        -----------------------------------------------------------------------
        NETWORK SUCCESS
        Request method: GET
        On https://someserver.com
        Code: 200

        Request data:
        RequestData

        Response data:
        ResponseData
        Request Headers:
        headerField1:  headerField1
        -----------------------------------------------------------------------


        """
        XCTAssertEqual(log.debugText[0], expectedLogText)
        XCTAssertEqual(log.debugText.count, 1)
    }
    
    func test_logDataTaskFailure() {
        let log = MockLog()
        let sut = Logger(log: log)
        var request = URLRequest(url: testURL)
        request.httpBody = "RequestData".data(using: String.Encoding.utf8)!
        request.allHTTPHeaderFields = ["headerField1":"headerField1"]
        let response = HTTPURLResponse(url: testURL, statusCode: 400, httpVersion: "httpVersion", headerFields: ["header1":"header1"])!
        let responseData = "ResponseData".data(using: String.Encoding.utf8)!
        XCTAssertEqual(log.debugText.count, 0)
        sut.logDataTaskFailure(attempting: "Tried to do something", error: "Error!", request: request, response: response, responseData: responseData)
        let expectedLogText = """



        -----------------------------------------------------------------------
        NETWORK ERROR
        attempting: Tried to do something
        Description: The operation couldn’t be completed. (Swift.String error 1.)
        Request method: GET
        On https://someserver.com
        Code: 400

        Request data:
        RequestData

        Response data:
        ResponseData
        Request Headers:
        headerField1:  headerField1
        -----------------------------------------------------------------------


        """
        XCTAssertEqual(log.errorText[0], expectedLogText)
        XCTAssertEqual(log.errorText.count, 1)
        XCTAssertEqual(log.notifiedErrors.count, 1)
    }

}

extension String : Error {}
