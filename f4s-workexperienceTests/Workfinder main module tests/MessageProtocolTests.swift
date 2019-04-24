//
//  MessageProtocolTests.swift
//  MessagerTests
//
//  Created by Keith Staines on 23/11/2018.
//  Copyright © 2018 Keith Staines. All rights reserved.
//

import XCTest
@testable import f4s_workexperience

class MessageProtocolTests: XCTestCase {
    
    let senderId = "me123"
    
    override func setUp() {
        
    }
    
    override func tearDown() {
        
    }
    
    func testMessageInitialization() {
        
        let message = Message(senderId: senderId)
        XCTAssertEqual(message.senderId, senderId)
    }
    
    func testDateToOrderBy_withNoDates() {
        let message = Message(senderId: senderId)
        XCTAssertEqual(message.dateToOrderBy, Date.distantFuture)
    }
    
    func testDateToOrderBy_withSentDate() {
        let sendDate = Date().addingTimeInterval(3600)
        var message = Message(senderId: senderId)
        message.sentDate = sendDate
        XCTAssertEqual(message.dateToOrderBy, sendDate)
    }
    
    func testDateToOrderBy_withReceivedDate() {
        let receivedDate = Date().addingTimeInterval(3600)
        var message = Message(senderId: senderId)
        message.receivedDate = receivedDate
        XCTAssertEqual(message.dateToOrderBy, receivedDate)
    }
    
    func testDateToOrderBy_withSentAndReceivedDates() {
        let receivedDate = Date().addingTimeInterval(3600)
        let sentDate = Date().addingTimeInterval(-1800)
        var message = Message(senderId: senderId)
        message.receivedDate = receivedDate
        message.sentDate = sentDate
        XCTAssertEqual(message.dateToOrderBy, sentDate)
    }
    
    func testIsRead_whenNotRead() {
        let message = Message(senderId: senderId)
        XCTAssertNil(message.isRead)
        XCTAssertNil(message.readDate)
    }
    
    func testIsEqual_whenIsEqual() {
        let message = Message(senderId: "sender")
        let exactCopy = message
        XCTAssertTrue(message.isEqual(other: exactCopy))
    }
    
    func testIsEqual_whenUuidsAreEqual() {
        var message1 = Message(senderId: "a")
        var message2 = Message(senderId: "b")
        message1.uuid = "1234"
        message2.uuid = "1234"
        XCTAssertTrue(message1.isEqual(other: message2))
    }
    
    func testIsEqual_whenUuidsAreNotEqual() {
        var message1 = Message(senderId: "a")
        var message2 = Message(senderId: "a")
        message1.uuid = "1234"
        message2.uuid = "4321"
        XCTAssertTrue(message1.isEqual(other: message2))
    }
    
}

