//
//  F4SUserModel.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 19/06/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation
import KeychainSwift
import Analytics
import WorkfinderCommon

public struct F4SPushNotificationStatus : Decodable {
    public var enabled: Bool?
    public var errors: F4SJSONValue?
}

public struct F4SPushToken: Encodable {
    public var pushToken: String
}

extension F4SPushToken {
    private enum CodingKeys : String, CodingKey {
        case pushToken = "push_token"
    }
}

public struct F4SRegisterResult : Decodable {
    public var uuid: F4SUUID?
    public var errors: F4SJSONValue?
}

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

//public struct F4SUserUpdateJson : Codable {
//    public var uuid: F4SUUID?
//    public var email: String
//    public var consenterEmail: String?
//    public var firstName: String
//    public var lastName: String?
//    public var dateOfBirth: String
//    public var requiresConsent: Bool
//    public var placementUuid: F4SUUID
//    public var partners: [F4SPartnerJson]
//    
//    public init(uuid: String? = nil, email: String = "", firstName: String = "", lastName: String = "", consenterEmail: String = "", dateOfBirth: String = "", requiresConsent: Bool = false, placementUuid: String = "", partners: [F4SPartnerJson] = []) {
//        self.uuid = uuid
//        self.email = email
//        self.firstName = firstName
//        self.lastName = lastName
//        self.consenterEmail = consenterEmail
//        self.dateOfBirth = dateOfBirth
//        self.requiresConsent = false
//        self.placementUuid = placementUuid
//        self.partners = partners
//    }
//}
//
//extension F4SUserUpdateJson {
//    private enum CodingKeys : String, CodingKey {
//        case uuid
//        case email
//        case firstName = "first_name"
//        case lastName = "last_name"
//        case consenterEmail = "consenter_email"
//        case dateOfBirth = "date_of_birth"
//        case requiresConsent = "requires_consent"
//        case placementUuid = "placement_uuid"
//        case partners
//    }
//}

public struct F4SAnonymousUser : Codable {
    public var vendorUuid: String
    public var clientType: String
    public var apnsEnvironment: String
}

extension F4SAnonymousUser {
    private enum CodingKeys : String, CodingKey {
        case vendorUuid = "vendor_uuid"
        case  clientType = "type"
        case apnsEnvironment = "env"
    }
}

public protocol F4SUserProtocol {
    var uuid: F4SUUID? { get }
    var isRegistered: Bool { get }
    var isOnboarded: Bool { get }
    mutating func updateUuid(uuid: F4SUUID)
}

public struct F4SUser : F4SUserProtocol, Codable {
    
    var localStore: LocalStorageProtocol = UserDefaults.standard
    var analytics: F4SAnalytics? = f4sLog
    
    public private (set) var uuid: F4SUUID?
    public var consenterEmail: String?
    public var parentEmail: String?
    public var dateOfBirth: Date?
    public var placementUuid: String?
    public var email: String
    public var firstName: String
    public var requiresConsent: Bool? = false
    
    public var lastName: String? {
        didSet {
            assert(lastName == nil || lastName?.isEmpty == false)
        }
    }
    
    public var isOnboarded: Bool {
        guard let isFirstLaunch = localStore.value(key: LocalStore.Key.isFirstLaunch) as? Bool else { return false }
        return !isFirstLaunch
    }
    
    public func didFinishOnboarding() {
        localStore.setValue(false, for: LocalStore.Key.isFirstLaunch)
    }
    
    public static func loadFromLocalPermanentStore() -> F4SUser? {
        return UserInfoDBOperations.sharedInstance.getUserInfo()
    }
    
    public func age(on date: Date = Date()) -> Int? {
        guard let userBirthday = dateOfBirth else { return nil }
        let calendar = NSCalendar.current
        let ageComponents = calendar.dateComponents([.year], from: userBirthday, to: date)
        let age = ageComponents.year!
        return age
    }
    
    public init(localStore: LocalStorageProtocol = UserDefaults.standard) {
        self.localStore = localStore
        uuid = localStore.value(key: LocalStore.Key.userUuid) as! F4SUUID?
        firstName = ""
        email = ""
    }
    
    init(userData: UserInfoDB) {
        self.init()
        email = userData.email ?? ""
        firstName = userData.firstName ?? ""
        lastName = userData.lastName?.isEmpty == false ? userData.lastName : nil
        consenterEmail = userData.consenterEmail
        parentEmail = userData.consenterEmail
        placementUuid = userData.placementUuid
        if let dateOfBirth = userData.dateOfBirth {
            self.dateOfBirth =  Date.dateFromRfc3339(string: dateOfBirth)
        }
    }
    
    public var isRegistered: Bool { return uuid != nil }
    
    public mutating func updateUuid(uuid: F4SUUID) {
        guard uuid != self.uuid else { return }
        self.uuid = uuid
        localStore.setValue(uuid, for: LocalStore.Key.userUuid)
        analytics?.alias(userId: uuid)
    }
    
    public static func dataFixMoveUUIDFromKeychainToUserDefaults() {
        let keychain = KeychainSwift()
        guard let uuid = keychain.get(UserDefaultsKeys.userUuid) else { return }
        UserDefaults.standard.setValue(uuid, forKey: UserDefaultsKeys.userUuid)
        KeychainSwift().delete(UserDefaultsKeys.userUuid)
    }

}

extension F4SUser {
    private enum CodingKeys : String, CodingKey {
        case uuid
        case firstName = "first_name"
        case lastName = "last_name"
        case email
        case dateOfBirth = "date_of_birth"
        case requiresConsent = "requires_consent"
        case consenterEmail = "consenter_email"
        case parentEmail = "parent_email"
        case placementUuid = "placement_uuid"
    }
}

