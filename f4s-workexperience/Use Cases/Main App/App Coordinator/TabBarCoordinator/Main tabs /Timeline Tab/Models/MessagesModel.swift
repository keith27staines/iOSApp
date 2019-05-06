//
//  MessagesModel.swift
//  Messager
//
//  Created by Keith Staines on 24/11/2018.
//  Copyright © 2018 Keith Staines. All rights reserved.
//

import Foundation
import WorkfinderCommon

public struct MessagesModel {
    
    public let outgoingSenderId: String
    
    public let numberOfSections = 1
    
    public func numberOfRowsInSection(_ section: Int) -> Int {
        return messages.count
    }
    
    public func messageForIndexPath(_ indexPath: IndexPath) -> MessageProtocol {
        return messages[indexPath.row]
    }
    
    public init(outgoingSenderId: String, messages: [MessageProtocol]) {
        self.outgoingSenderId = outgoingSenderId
        self.messages = messages.sorted(by: { (message1, message2) -> Bool in
            return message1.dateToOrderBy <= message2.dateToOrderBy
        })
    }
    
    public func contains(_ message: MessageProtocol) -> Bool {
        let matchingMessage = messages.first(where: { (existingMessage) -> Bool in
            existingMessage.isEqual(other: message)
        })
        return matchingMessage == nil ? false : true
    }
    
    public mutating func updateMessage(_ message: MessageProtocol) -> Bool {
        guard let matchingIndex = messages.firstIndex(where: { (existingMessage) -> Bool in
            existingMessage.isEqual(other: message)
        }) else { return false }
        messages[matchingIndex] = message
        return true
    }
    
    public mutating func insertMessage(_ message: MessageProtocol) -> IndexPath? {
        guard contains(message) == false else { return nil }
        
        if messages.isEmpty {
            messages.append(message)
            return IndexPath(row: 0, section: 0)
        }
        
        let firstLaterIndex = messages.firstIndex { (otherMessage) -> Bool in
            otherMessage.dateToOrderBy > message.dateToOrderBy
        }
        
        if let firstLaterIndex = firstLaterIndex {
            messages.insert(message, at: firstLaterIndex)
            return IndexPath(row: firstLaterIndex, section: 0)
        } else {
            messages.append(message)
            return IndexPath(row: messages.count - 1, section: 0)
        }
    }
    
    var messages: [MessageProtocol] = []
}

