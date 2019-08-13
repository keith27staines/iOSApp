//
//  F4SPlacement.swift
//  WorkfinderCommon
//
//  Created by Keith Dev on 06/04/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation


/// Models a work experience placement application
public struct F4SPlacement : Codable {
    /// company at which the placement takes place
    public var companyUuid: F4SUUID?
    /// interests of the user
    public var interestList: [F4SInterest]
    /// status of the application
    public var status: WEXPlacementState?
    /// the unique id of the placement application
    public var placementUuid: F4SUUID?
    /// the unique uuid of the user
    public var userUuid: F4SUUID?
    
    
    /// Initialise a new instance with the parameters provided
    ///
    /// - Parameters:
    ///   - userUuid: the unique uuid of the user
    ///   - companyUuid: the unique uuid of the company being applied to
    ///   - interestList: a list of interests of the user
    ///   - status: the status of the application
    ///   - placementUuid: the unique uuid of the application
    public init(userUuid: F4SUUID? = nil, companyUuid: F4SUUID? = nil, interestList: [F4SInterest] = [], status: WEXPlacementState? = nil, placementUuid: F4SUUID? = nil) {
        self.userUuid = userUuid
        self.companyUuid = companyUuid
        self.interestList = interestList
        self.status = status
        self.placementUuid = placementUuid
    }
    
    
    /// Initialise a new instance from a timeline placement
    ///
    /// - Parameter timelinePlacement: the timeline placement
    public init(timelinePlacement: F4STimelinePlacement) {
        self.userUuid = timelinePlacement.userUuid
        self.companyUuid = timelinePlacement.companyUuid
        self.placementUuid = timelinePlacement.placementUuid
        self.status = timelinePlacement.workflowState
        self.interestList = []
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
