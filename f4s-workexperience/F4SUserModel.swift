//
//  F4SUserModel.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 19/06/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation

public struct F4SUser : Codable {
    public var email: String
    public var firstName: String
    public var lastName: String
    public var consenterEmail: String
    public var dateOfBirth: String
    public var requiresConsent: Bool
    public var placementUuid: String
    
    public init(email: String = "", firstName: String = "", lastName: String = "", consenterEmail: String = "", dateOfBirth: String = "", requiresConsent: Bool = false, placementUuid: String = "") {
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.consenterEmail = consenterEmail
        self.dateOfBirth = dateOfBirth
        self.requiresConsent = false
        self.placementUuid = placementUuid
    }
}
