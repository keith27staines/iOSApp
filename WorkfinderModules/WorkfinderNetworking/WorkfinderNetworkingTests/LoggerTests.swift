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
        let log = MockF4SAnalyticsAndDebugging()
        log.alias(userId: "123456789")
        let sut = NetworkCallLogger(log: log)
        XCTAssertEqual((sut.log as? MockF4SAnalyticsAndDebugging)!.aliases.last, "123456789")
    }
    
    func test_logDataTaskSuccess_with_valid_data() {
        let log = MockF4SAnalyticsAndDebugging()
        let sut = NetworkCallLogger(log: log)
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
        XCTAssertEqual(log.debugMessages[0], expectedLogText)
        XCTAssertEqual(log.debugMessages.count, 1)
    }
    
    func test_connection_error_is_not_notified() {
        let log = MockF4SAnalyticsAndDebugging()
        let sut = NetworkCallLogger(log: log)
        let error = WorkfinderError(errorType: .networkConnectivity, attempting: "")
        sut.logDataTaskFailure(error: error)
        XCTAssertEqual(log.loggedErrorMessages.count, 1)
        XCTAssertEqual(log.notifiedErrors.count, 0)
    }
    
    func test_logDataTaskFailure_format_and_is_notified() {
        let log = MockF4SAnalyticsAndDebugging()
        let sut = NetworkCallLogger(log: log)
        var request = URLRequest(url: testURL)
        request.httpBody = "RequestData".data(using: String.Encoding.utf8)!
        request.allHTTPHeaderFields = ["headerField1":"headerField1"]
        request.httpMethod = "POST"
        let response = HTTPURLResponse(url: testURL, statusCode: 400, httpVersion: "httpVersion", headerFields: ["header1":"header1"])!
        let responseData = "ResponseData".data(using: String.Encoding.utf8)!
        XCTAssertEqual(log.debugMessages.count, 0)
        let error = WorkfinderError(response: response, retryHandler: nil)!
        error.urlRequest = request
        error.responseData = responseData
        sut.logDataTaskFailure(error: error)
        XCTAssertEqual(log.loggedErrorMessages[0], expectedLogText)
        XCTAssertEqual(log.loggedErrorMessages.count, 1)
        XCTAssertEqual(log.notifiedErrors.count, 1)
    }

}

extension String : Error {}


/// This is the expected text for the network error log
fileprivate let expectedLogText = """



-----------------------------------------------------------------------
NETWORK ERROR
Title: Server error 400
Description: Bad request
Request method: POST
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
