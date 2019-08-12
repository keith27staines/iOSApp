//
//  WEXMessageTests.swift
//  WorkfinderCommonTests
//
//  Created by Keith Dev on 12/08/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import XCTest
@testable import WorkfinderCommon

class WEXMessageTests: XCTestCase {

    func test_initialise() {
        let date = Date()
        let sut = WEXMessage(uuid: "uuid", dateTime: date, relativeDateTime: "relativeDatetime", content: "content", sender: "sender")
        XCTAssertTrue(sut.uuid == "uuid")
        XCTAssertTrue(sut.dateTime == date)
        XCTAssertTrue(sut.relativeDateTime == "relativeDatetime")
        XCTAssertTrue(sut.content == "content")
        XCTAssertTrue(sut.sender == "sender")
    }
    
    func test_decode() {
        let date = DateComponents(calendar: Calendar.current, timeZone: TimeZone(secondsFromGMT: 0), year: 2010, month: 1, day: 2, hour: 3, minute: 4, second: 5).date!
        let json = """
        {
            \"uuid\": \"uuid\",
            \"datetime\": \"2010-01-02T03:04:05Z\",
            \"datetime_rel\": \"relativeDatetime\",
            \"content\": \"content\",
            \"sender\": \"sender\"
        }
        """
        let data = json.data(using: String.Encoding.utf8)!
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let sut = try! decoder.decode(WEXMessage.self, from: data)
        XCTAssertTrue(sut.uuid == "uuid")
        XCTAssertTrue(sut.dateTime == date)
        XCTAssertTrue(sut.relativeDateTime == "relativeDatetime")
        XCTAssertTrue(sut.content == "content")
        XCTAssertTrue(sut.sender == "sender")
    }

}
