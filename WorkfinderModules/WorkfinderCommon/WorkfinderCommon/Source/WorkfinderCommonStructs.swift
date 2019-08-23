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

public struct F4SPartner : Codable {
    public var uuid: F4SUUID
    public var name: String
    public var description: String? = ""
    public var imageUrlString: String? = nil
    public var sortingIndex: Int = 0
    public var isPlaceholder: Bool? = false
    
    /// The name of an image that can be used to represent the partner in an icon
    public var imageName: String? = nil
    
    /// An image that can be used to represent the partner in an icon
    public var image: UIImage? {
        guard let imageName = self.imageName else { return nil }
        return UIImage(named: imageName)
    }
    
    public init(uuid: F4SUUID, name: String) {
        self.uuid = uuid
        self.name = name
    }
    
    public init(uuid: F4SUUID, sortingIndex: Int, name: String, description: String?, imageName: String?) {
        self.uuid = uuid
        self.sortingIndex = sortingIndex
        self.name = name
        self.description = description
        self.imageName = imageName
    }
    
    /// A placeholder partner used while waiting for the user to provide one
    public static var partnerProvidedLater: F4SPartner {
        let name = NSLocalizedString("I will provide this later", comment: "Inform the user that they can skip providing this information now, but it might be requested again later")
        var p = F4SPartner(uuid: SystemF4SUUID.willProvideLater.rawValue, name: name)
        p.sortingIndex = Int.max
        p.isPlaceholder = true
        return p
    }
}

private extension F4SPartner {
    // Only include keys for member variables that are part of the server-side partner model
    enum CodingKeys  : String, CodingKey  {
        case uuid
        case name
        case description
        case imageUrlString = "logo"
    }
}

public enum SystemF4SUUID : F4SUUID {
    case willProvideLater = "willProvideLater"
}
