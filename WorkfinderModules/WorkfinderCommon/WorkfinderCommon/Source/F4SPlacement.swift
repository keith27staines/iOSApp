//
//  F4SPlacement.swift
//  WorkfinderCommon
//
//  Created by Keith Dev on 06/04/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation

public struct F4SPlacement : Codable {
    public var companyUuid: F4SUUID?
    public var interestList: [F4SInterest]
    public var status: WEXPlacementState?
    public var placementUuid: F4SUUID?
    public var userUuid: F4SUUID?
    
    public init(userUuid: F4SUUID? = nil, companyUuid: F4SUUID? = nil, interestList: [F4SInterest] = [], status: WEXPlacementState? = nil, placementUuid: F4SUUID? = nil) {
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
