//
//  F4SPlacementModels.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 21/06/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation


public enum F4SPlacementStatus : String, Codable {
    case inProgress = "in_progress"
    case applied
    case accepted
    case rejected
    case confirmed
    case completed
    case draft
    case noAge =  "no_age"
    case noVoucher = "no_voucher"
    case noParentalConsent = "no_parental_consent"
    case unsuccessful
    case moreInfoRequested = "more info requested"
}

public struct F4STimelinePlacement : Codable {
    public var placementUuid: F4SUUID?
    public var userUuid: F4SUUID?
    public var companyUuid: F4SUUID?
    public var threadUuid: F4SUUID?
    public var isRead: Bool?
    public var state: F4SPlacementStatus?
    public var latestMessage: F4SMessage?
}

extension F4STimelinePlacement {
    private enum CodingKeys : String, CodingKey {
        case threadUuid = "thread_uuid"
        case placementUuid = "uuid"
        case userUuid = "user_uuid"
        case companyUuid = "company_uuid"
        case isRead = "is_read"
        case state
        case latestMessage = "latest_message"
    }
}

extension F4STimelinePlacement : Equatable {
    public static func ==(lhs: F4STimelinePlacement, rhs: F4STimelinePlacement) -> Bool {
        return
            lhs.companyUuid == rhs.companyUuid &&
                lhs.isRead == rhs.isRead &&
                lhs.latestMessage?.uuid == rhs.latestMessage?.uuid &&
                lhs.placementUuid ==  rhs.placementUuid &&
                lhs.state == rhs.state &&
                lhs.threadUuid == rhs.threadUuid &&
                lhs.userUuid == rhs.userUuid
    }
}

// MARK: - Placment

public struct F4SPlacement : Codable {
    public var companyUuid: F4SUUID?
    public var interestList: [F4SInterest]
    public var status: F4SPlacementStatus?
    public var placementUuid: F4SUUID?
    public var userUuid: F4SUUID?
    
    public init(userUuid: F4SUUID? = nil, companyUuid: F4SUUID? = nil, interestList: [F4SInterest] = [], status: F4SPlacementStatus? = nil, placementUuid: F4SUUID? = nil) {
        self.userUuid = userUuid
        self.companyUuid = companyUuid
        self.interestList = interestList
        self.status = status
        self.placementUuid = placementUuid
    }
}

extension F4SPlacement {
    private enum CodingKeys : String, CodingKey {
        case userUuid = "user_uuid"
        case companyUuid = "company_uuid"
        case status
        case placementUuid = "placement_uuid"
        case interestList = "interests"
    }
}

/// The json object returned from the create placement api
public struct F4SPlacementCreateResult : Decodable {
    public var placementUuid: F4SUUID?
    public var errors: F4SJSONValue?
}

extension F4SPlacementCreateResult {
    private enum CodingKeys : String, CodingKey {
        case placementUuid = "uuid"
        case errors
    }
}

//// MARK:- Timeline
//public struct F4STimeline : Codable {
//    public var placementUuid: String?
//    public var userUuid: String
//    public var companyUuid: String
//    public var threadUuid: String
//    public var placementStatus: F4SPlacementStatus?
//    public var latestMessage: F4SMessage
//    public var isRead: Bool
//    
//    public init(placementUuid: String? = nil, userUuid: String = "", companyUuid: String = "", threadUuid: String = "", placementStatus: F4SPlacementStatus? = .inProgress, latestMessage: F4SMessage = F4SMessage(), isRead: Bool = true) {
//        self.placementUuid = placementUuid
//        self.companyUuid = companyUuid
//        self.userUuid = userUuid
//        self.threadUuid = threadUuid
//        self.placementStatus = placementStatus
//        self.latestMessage = latestMessage
//        self.isRead = isRead
//    }
//}
//
//extension F4STimeline {
//    private enum CodingKeys : String, CodingKey {
//        case placementUuid = "placement_uuid"
//        case userUuid = "user_uuid"
//        case companyUuid = "company_uuid"
//        case threadUuid = "thread_uuid"
//        case placementStatus = "placement_status"
//        case latestMessage = "latest_message"
//        case isRead = "is_Read"
//    }
//}

// MARK:- The user's interests
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
    public var hashValue: Int { return uuid.hashValue }
}
