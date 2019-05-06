//
//  MessagesModelTests.swift
//  MessagerTests
//
//  Created by Keith Staines on 24/11/2018.
//  Copyright © 2018 Keith Staines. All rights reserved.
//

import XCTest
import UIKit
import WorkfinderCommon
@testable import f4s_workexperience

class MessagesModelTests: XCTestCase {
    
    let outgoingSenderId = "me456"
    var messages: [MessageProtocol]!
    var model: MessagesModel!
    var earliestMessage: Message!
    var middleMessage: Message!
    var latestMessage: Message!
    
    override func setUp() {
        earliestMessage = Message(senderId: outgoingSenderId)
        earliestMessage.sentDate = Date().addingTimeInterval(-7200)
        earliestMessage.text = "earliest"
        
        middleMessage = Message(senderId: "someoneElse")
        middleMessage.text = "middle"
        middleMessage.sentDate = Date().addingTimeInterval(-3600)
        
        latestMessage = Message(senderId: outgoingSenderId)
        latestMessage.text = "latest"
        latestMessage.sentDate = Date().addingTimeInterval(-1800)
        
        // deliberately in completely the wrong order, model should sort by date...
        messages = [middleMessage,latestMessage,earliestMessage]
        model = MessagesModel(outgoingSenderId: outgoingSenderId, messages: messages)
    }
    
    override func tearDown() {
        messages = nil
    }
    
    func testOutgoingSenderId() {
        XCTAssertEqual(model.outgoingSenderId, outgoingSenderId)
    }
    
    func testNumberOfSections() {
        XCTAssertEqual(model.numberOfSections, 1)
    }
    
    func testNumberOfRowsInSection() {
        XCTAssertEqual(model.numberOfRowsInSection(0), messages.count)
    }
    
    func testMessageForIndexPath() {
        let indexPath0 = IndexPath(row: 0, section: 0)
        let indexPath1 = IndexPath(row: 1, section: 0)
        let indexPath2 = IndexPath(row: 2, section: 0)
        let earliestMessage = model.messageForIndexPath(indexPath0)
        let middleMessage = model.messageForIndexPath(indexPath1)
        let latestMessage = model.messageForIndexPath(indexPath2)
        XCTAssertEqual(earliestMessage.sentDate, earliestMessage.sentDate)
        XCTAssertEqual(middleMessage.sentDate, middleMessage.sentDate)
        XCTAssertEqual(latestMessage.sentDate, latestMessage.sentDate)
    }
    
    func testContains_whereDoesContain() {
        let middleMessage = self.middleMessage!
        XCTAssertEqual(model.contains(middleMessage), true)
    }
    
    func testContains_whereDoesNotContain() {
        var randomMessage = Message(senderId: "fhdjskahfjdk")
        randomMessage.sentDate = Date.distantPast
        XCTAssertEqual(model.contains(randomMessage), false)
    }
    
    func testInsertMessage_messageAlreadyExists() {
        let middleMessage = self.middleMessage!
        let insertedIndexPath = model.insertMessage(middleMessage)
        XCTAssertNil(insertedIndexPath)
    }
    
    func testInsertMessage_intoEmptyModel() {
        var model = MessagesModel(outgoingSenderId: outgoingSenderId, messages: [])
        let message = Message(senderId: "some sender")
        let indexPath = model.insertMessage(message)!
        XCTAssertEqual(indexPath.row, 0)
        XCTAssertTrue(message.isEqual(other: model.messages.first!))
        XCTAssertEqual(model.messages.count, 1)
    }
    
    func testInsertMessage_messageSentBeforeAnyExisting() {
        var newMessage = Message(senderId: "randomPerson")
        newMessage.sentDate = earliestMessage.dateToOrderBy.addingTimeInterval(-1)
        let insertedIndexPath = model.insertMessage(newMessage)!
        XCTAssertEqual(insertedIndexPath.row, 0)
    }
    
    func testInsertMessage_messageSentAfterAnyExisting() {
        var newMessage = Message(senderId: "randomPerson")
        newMessage.sentDate = latestMessage.dateToOrderBy.addingTimeInterval(1)
        let insertedIndexPath = model.insertMessage(newMessage)!
        XCTAssertEqual(insertedIndexPath.row, model.messages.count-1)
    }
    
    func testInsertMessage_messageSentImmediatelyAfterFirst() {
        var newMessage = Message(senderId: "randomPerson")
        newMessage.sentDate = earliestMessage.dateToOrderBy.addingTimeInterval(1)
        let insertedIndexPath = model.insertMessage(newMessage)!
        XCTAssertEqual(insertedIndexPath.row, 1)
    }
    
    func testInsertMessage_messageSentImmediatelyBeforeLast() {
        var newMessage = Message(senderId: "randomPerson")
        newMessage.sentDate = latestMessage.dateToOrderBy.addingTimeInterval(-1)
        let insertedIndexPath = model.insertMessage(newMessage)!
        XCTAssertEqual(insertedIndexPath.row, model.messages.count - 2)
    }
    
    func testUpdateMessage_whereMessageNotPresent() {
        let message = Message(senderId: "fjdsljfkd")
        let updateSuccess = model.updateMessage(message)
        XCTAssertFalse(updateSuccess)
    }
    
    func testUpdateMessage_whereMessageIsPresent() {
        var message = middleMessage!
        message.text = "this message was updated"
        let updateSuccess = model.updateMessage(message)
        XCTAssertTrue(updateSuccess)
        XCTAssertEqual(message.text!, model.messages[1].text!)
    }
}

