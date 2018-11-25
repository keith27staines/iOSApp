//
//  MessageProtocol.swift
//  Messager
//
//  Created by Keith Staines on 24/11/2018.
//  Copyright © 2018 Keith Staines. All rights reserved.
//

import Foundation

public protocol MessageProtocol {
    var uuid: String { get }
    var senderId: String { get }
    var sentDate: Date? { get }
    var receivedDate: Date? { get }
    var readDate: Date? { get }
    var isRead: Bool { get }
    var text: String? { get }
}

public extension MessageProtocol {
    
    func isEqual(other: MessageProtocol) -> Bool {
        if uuid == other.uuid { return true }
        return self.dateToOrderBy == other.dateToOrderBy && self.senderId == other.senderId
    }
    
    var isRead: Bool { return readDate != nil }
    
    var dateToOrderBy: Date {
        return sentDate ?? receivedDate ?? Date.distantFuture
    }
}

