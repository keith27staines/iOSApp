//
//  WorkfinderCommonStructs.swift
//  WorkfinderCommon
//
//  Created by Keith Dev on 21/07/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation

public struct F4SPushNotificationStatus : Decodable {
    public var enabled: Bool?
    public var errors: F4SJSONValue?
}

public struct F4SPushToken: Encodable {
    public var pushToken: String
    public init(pushToken: String) {
        self.pushToken = pushToken
    }
}

extension F4SPushToken {
    private enum CodingKeys : String, CodingKey {
        case pushToken = "push_token"
    }
}

public struct F4SRegisterDeviceResult : Decodable {
    public var uuid: F4SUUID?
    public var errors: F4SJSONValue?
    public init(userUuid: F4SUUID) {
        self.uuid = userUuid
    }
    public init(errors: F4SJSONValue?) {
        self.errors = errors
    }
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
    public init(vendorUuid: F4SUUID, clientType: String, apnsEnvironment: String) {
        self.vendorUuid = vendorUuid
        self.clientType = clientType
        self.apnsEnvironment = apnsEnvironment
    }
}

extension F4SAnonymousUser {
    private enum CodingKeys : String, CodingKey {
        case vendorUuid = "vendor_uuid"
        case  clientType = "type"
        case apnsEnvironment = "env"
    }
}
