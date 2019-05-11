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

extension F4SUser {
    public static func dataFixMoveUUIDFromKeychainToUserDefaults() {
        let keychain = KeychainSwift()
        guard let uuid = keychain.get(UserDefaultsKeys.userUuid) else { return }
        UserDefaults.standard.setValue(uuid, forKey: UserDefaultsKeys.userUuid)
        KeychainSwift().delete(UserDefaultsKeys.userUuid)
    }
}

