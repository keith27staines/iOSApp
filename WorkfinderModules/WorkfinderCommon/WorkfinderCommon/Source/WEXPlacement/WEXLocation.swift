//
//  WEXLocation.swift
//  WorkfinderCommon
//
//  Created by Keith Dev on 15/03/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation

public struct WEXLocationJson : Codable {
    public var address: WEXAddressJson?
    public var phoneNumber: String?
    public var website: String?
    public var point: WEXPointJson?
}

extension WEXLocationJson {
    private enum CodingKeys : String, CodingKey {
        case address
        case phoneNumber = "phone_number"
        case website
        case point
    }
}

public struct WEXAddressJson : Codable {
    public var building: String?
    public var street: String?
    public var address3: String?
    public var town: String?
    public var locality: String?
    public var county: String?
    public var postcode: String?
}

public struct WEXPointJson : Codable {
    public var latitude: Double
    public var longitude: Double
}

extension WEXPointJson {
    private enum CodingKeys : String, CodingKey {
        case latitude = "lat"
        case longitude = "long"
    }
}
