//
//  WorkfinderCommonStructs.swift
//  WorkfinderCommon
//
//  Created by Keith Dev on 21/07/2019.
//  Copyright © 2019 Workfinder Ltd. All rights reserved.
//

import Foundation

public struct F4SPushNotificationStatus : Decodable {
    public var enabled: Bool?
    public var errors: F4SJSONValue?
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

public struct F4SUserModel : Decodable {
    public var uuid: F4SUUID?
    public var errors: F4SJSONValue?
    public init(uuid: F4SUUID? = nil, errors: F4SJSONValue? = nil) {
        self.uuid = uuid
        self.errors = errors
    }
}


