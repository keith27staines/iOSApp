//
//  WEXMessage.swift
//  WorkfinderCommon
//
//  Created by Keith Dev on 15/03/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation

/// Models a message received from the Workfinder server
public struct WEXMessage : Codable {
    /// The uuid of the message
    public var uuid: F4SUUID
    /// The date at which the message was sent
    public var dateTime: Date?
    /// A string describing how long ago the message was sent
    public var relativeDateTime: String?
    /// The main body of the message
    public var content: String
    /// A string identifying the sender
    public var sender: String?
    
    /// Initialise a new instance
    ///
    /// - Parameters:
    ///   - uuid: the uuid of the message
    ///   - dateTime: the datetime at which the message was sent
    ///   - relativeDateTime: describes how long ago the message was sentg
    ///   - content: the main body of the message
    ///   - sender: a string identifying the sender
    public init(uuid: String = "", dateTime: Date = Date(), relativeDateTime: String = "", content: String = "", sender: String = "") {
        self.uuid = uuid
        self.dateTime = dateTime
        self.relativeDateTime = relativeDateTime
        self.content = content
        self.sender = sender
    }
}

extension WEXMessage {
    private enum CodingKeys : String, CodingKey {
        case uuid
        case dateTime = "datetime"
        case relativeDateTime = "datetime_rel"
        case content
        case sender
    }
}
