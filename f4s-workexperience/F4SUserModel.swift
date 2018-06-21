//
//  F4SUserModel.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 19/06/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation

public struct F4SPartnerJson : Codable {
    public var uuid: F4SUUID
}

public struct F4SUserModel : Decodable {
    public var uuid: F4SUUID?
    public var errors: F4SJSONValue?
    public init(uuid: F4SUUID? = nil, errors: F4SJSONValue? = nil) {
        self.uuid = uuid
        self.errors = errors
    }
}

public struct F4SUserUpdateJson : Codable {
    public var uuid: F4SUUID?
    public var email: String
    public var consenterEmail: String?
    public var firstName: String
    public var lastName: String?
    public var dateOfBirth: String
    public var requiresConsent: Bool
    public var placementUuid: F4SUUID
    public var partners: [F4SPartnerJson]
    
    public init(uuid: String? = nil, email: String = "", firstName: String = "", lastName: String = "", consenterEmail: String = "", dateOfBirth: String = "", requiresConsent: Bool = false, placementUuid: String = "", partners: [F4SPartnerJson] = []) {
        self.uuid = uuid
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.consenterEmail = consenterEmail
        self.dateOfBirth = dateOfBirth
        self.requiresConsent = false
        self.placementUuid = placementUuid
        self.partners = partners
    }
}

extension F4SUserUpdateJson {
    private enum CodingKeys : String, CodingKey {
        case uuid
        case email
        case firstName = "first_name"
        case lastName = "last_name"
        case consenterEmail = "consenter_email"
        case dateOfBirth = "date_of_birth"
        case requiresConsent = "requires_consent"
        case placementUuid = "placement_uuid"
        case partners
    }
}

public struct F4SAnonymousUser : Codable {
    public var vendorUuid: String
    public var type: String
    public var env: String
}

public struct F4SUser : Codable {
    public var uuid: F4SUUID?
    public var email: String
    public var firstName: String
    public var lastName: String
    public var consenterEmail: String
    public var dateOfBirth: String
    public var requiresConsent: Bool
    public var placementUuid: String
    
    public init(uuid: String? = nil, email: String = "", firstName: String = "", lastName: String = "", consenterEmail: String = "", dateOfBirth: String = "", requiresConsent: Bool = false, placementUuid: String = "") {
        self.uuid = uuid
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.consenterEmail = consenterEmail
        self.dateOfBirth = dateOfBirth
        self.requiresConsent = false
        self.placementUuid = placementUuid
    }
}
