//
//  AllowedToApplyLogic.swift
//  WorkfinderAppLogic
//
//  Created by Keith Dev on 01/08/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation
import WorkfinderCommon
import WorkfinderNetworking
import WorkfinderServices


public class AllowedToApplyLogic {
    
    public let companyUuid: F4SUUID
    public internal (set) var userUuid: F4SUUID?
    var placementService: F4SPlacementServiceProtocol
    
    public init(userUuid: F4SUUID?,
                companyUuid: F4SUUID,
                placementsService: F4SPlacementServiceProtocol?) {
        self.userUuid = userUuid
        self.companyUuid = companyUuid
        self.placementService = placementsService!
    }
    
    public func checkIsAllowedToApply(completion: @escaping (F4SNetworkResult<Bool>) -> Void) {
        DispatchQueue.main.async {
            let result = F4SNetworkResult.success(true)
            completion(result)
        }
    }
    
}
