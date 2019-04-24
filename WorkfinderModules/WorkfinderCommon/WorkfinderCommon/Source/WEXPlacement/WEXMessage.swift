//
//  WEXMessage.swift
//  WorkfinderCommon
//
//  Created by Keith Dev on 15/03/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation

public struct WEXMessage : Codable {
    public var uuid: F4SUUID
    public var dateTime: Date?
    public var relativeDateTime: String?
    public var content: String
    public var sender: String?
    
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
