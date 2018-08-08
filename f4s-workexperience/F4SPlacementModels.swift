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
    case declined
    case completed
    case draft
    case noAge =  "no_age"
    case noVoucher = "no_voucher"
    case noParentalConsent = "no_parental_consent"
    case unsuccessful
    case moreInfoRequested = "more info requested"
    case referredByEmployer = "referred by employer"
}

public struct F4STimelinePlacement : Codable {
    public var placementUuid: F4SUUID?
    public var userUuid: F4SUUID?
    public var companyUuid: F4SUUID?
    public var threadUuid: F4SUUID?
    public var isRead: Bool?
    public var workflowState: F4SPlacementStatus?
    public var latestMessage: F4SMessage?
    public var roleUuid: F4SUUID?
    public var availabilityPeriods: [F4SAvailabilityPeriodJson]?
    public var voucher: String?
    public var totalHours: Double?
    public var duration: F4SAvailabilityPeriodJson?
    public var personResponsible: F4SPersonJson?
    public var location: F4SLocationJson?
}

extension F4STimelinePlacement {
    private enum CodingKeys : String, CodingKey {
        case threadUuid = "thread_uuid"
        case placementUuid = "uuid"
        case userUuid = "user_uuid"
        case companyUuid = "company_uuid"
        case isRead = "is_read"
        case workflowState = "workflow_state"
        case latestMessage = "latest_message"
        case roleUuid = "role_uuid"
        case availabilityPeriods = "availability_periods"
        case voucher
        case totalHours = "total_hours"
        case duration
        case personResponsible = "person_responsible"
        case location
    }
}

extension F4STimelinePlacement : Equatable {
    public static func ==(lhs: F4STimelinePlacement, rhs: F4STimelinePlacement) -> Bool {
        return
            lhs.companyUuid == rhs.companyUuid &&
                lhs.isRead == rhs.isRead &&
                lhs.latestMessage?.uuid == rhs.latestMessage?.uuid &&
                lhs.placementUuid ==  rhs.placementUuid &&
                lhs.workflowState == rhs.workflowState &&
                lhs.threadUuid == rhs.threadUuid &&
                lhs.userUuid == rhs.userUuid
    }
}

public struct F4SPersonJson : Codable {
    public var name: String?
    public var linkedinProfile: String?
    public var email: String?
}

extension F4SPersonJson {
    private enum CodingKeys : String, CodingKey {
        case name
        case linkedinProfile = "linkedin_profile"
        case email
    }
}

public struct F4SLocationJson : Codable {
    public var address: F4SAddressJson?
    public var phoneNumber: String?
    public var website: String?
    public var point: F4SPointJson?
}
    
extension F4SLocationJson {
    private enum CodingKeys : String, CodingKey {
        case address
        case phoneNumber = "phone_number"
        case website
        case point
    }
}

public struct F4SAddressJson : Codable {
    public var building: String?
    public var street: String?
    public var address3: String?
    public var town: String?
    public var locality: String?
    public var county: String?
    public var postcode: String?
}

public struct F4SPointJson : Codable {
    public var latitude: Double
    public var longitude: Double
}

extension F4SPointJson {
    private enum CodingKeys : String, CodingKey {
        case latitude = "lat"
        case longitude = "long"
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
