//
//  F4SInterest.swift
//  WorkfinderCommon
//
//  Created by Keith Dev on 06/04/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation

public struct F4SInterest : Codable {
    public static func ==(lhs: F4SInterest, rhs: F4SInterest) -> Bool {
        return lhs.uuid == rhs.uuid
    }
    
    public var id: Int
    public var uuid: F4SUUID
    public var name: String
    
    public init(id: Int = 0, uuid: F4SUUID = "", name: String = "") {
        self.id = id
        self.uuid = uuid
        self.name = name
    }
}

extension F4SInterest {
    private enum CodingKeys : String, CodingKey {
        case id
        case uuid
        case name
    }
}

extension F4SInterest : Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
}

public extension Sequence where Iterator.Element == F4SInterest {
    var uuidList: [F4SUUID] {
        return map({ (interest) -> F4SUUID in
            interest.uuid
        })
    }
}
