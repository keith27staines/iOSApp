//
//  WEXNetworkErrorTests.swift
//  WorkfinderCommonTests
//
//  Created by Keith Dev on 13/08/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import XCTest
@testable import WorkfinderCommon

class WEXNetworkErrorTests: XCTestCase {
    
    
    func test_initialise_with_non_retry_error() {
        let error = makeNSSError(code: 7, localizedDescription: "abc")
        let sut = WEXNetworkError(error: error, attempting: "something")
        XCTAssertEqual(sut.code, 7)
        XCTAssertEqual(sut.localizedDescription, "abc")
        XCTAssertFalse(sut.retry)
    }
    
    func test_initialise_with_not_connected_error() {
        let error = makeNSSError(code: NSURLErrorNotConnectedToInternet, localizedDescription: "abcdef")
        let sut = WEXNetworkError(error: error, attempting: "something")
        XCTAssertEqual(sut.code, NSURLErrorNotConnectedToInternet)
        XCTAssertEqual(sut.localizedDescription, "abcdef")
        XCTAssertTrue(sut.retry)
    }
    
    func test_initialise_with_lost_connection_error() {
        let error = makeNSSError(code: NSURLErrorNotConnectedToInternet, localizedDescription: "abcdef")
        let sut = WEXNetworkError(error: error, attempting: "something")
        XCTAssertEqual(sut.code, NSURLErrorNotConnectedToInternet)
        XCTAssertEqual(sut.localizedDescription, "abcdef")
        XCTAssertTrue(sut.retry)
    }
    
    func test_initialise_with_description() {
        let sut = WEXNetworkError(localizedDescription: "abc", attempting: "attempting", retry: true)
        XCTAssertEqual(sut.attempting, "attempting")
        XCTAssertNil(sut.code)
        XCTAssertEqual(sut.retry, true)
    }
    
    func test_initialise_with_response() {
        XCTAssertNotNil(makeWEXNetworkErrorWithResponseCode(199))
        XCTAssertNil(makeWEXNetworkErrorWithResponseCode(200))
        XCTAssertNil(makeWEXNetworkErrorWithResponseCode(250))
        XCTAssertNil(makeWEXNetworkErrorWithResponseCode(299))
        XCTAssertNotNil(makeWEXNetworkErrorWithResponseCode(300))
        XCTAssertTrue(makeWEXNetworkErrorWithResponseCode(429)!.retry)
        XCTAssertTrue(makeWEXNetworkErrorWithResponseCode(503)!.retry)
        XCTAssertFalse(makeWEXNetworkErrorWithResponseCode(400)!.retry)
        XCTAssertFalse(makeWEXNetworkErrorWithResponseCode(401)!.retry)
        XCTAssertFalse(makeWEXNetworkErrorWithResponseCode(403)!.retry)
        XCTAssertFalse(makeWEXNetworkErrorWithResponseCode(404)!.retry)
        XCTAssertFalse(makeWEXNetworkErrorWithResponseCode(500)!.retry)
        XCTAssertTrue(makeWEXNetworkErrorWithResponseCode(503)!.retry)
        XCTAssertFalse(makeWEXNetworkErrorWithResponseCode(999)!.retry)
    }
    
    func makeWEXNetworkErrorWithResponseCode(_ code: Int) -> WEXNetworkError? {
        let url = URL(string: "/api")!
        let response = HTTPURLResponse(url: url, statusCode: code, httpVersion: "version", headerFields: nil)!
        return WEXNetworkError(response: response, responseData: nil, attempting: "")
    }
    
    
    
    func makeNSSError(code: Int, localizedDescription: String = "abc") -> Error {
        let error = NSError(domain: "test", code: code, userInfo: [NSLocalizedDescriptionKey : localizedDescription])
        return error
    }

}

