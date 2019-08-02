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
    
    public lazy var placementService: F4SGetAllPlacementsServiceProtocol = {
        return F4SPlacementService()
    }()
    
    public init(service: F4SGetAllPlacementsServiceProtocol? = nil) {
        if let injectedPlacementService = service {
            self.placementService = injectedPlacementService
        }
    }
    
    public func checkUserCanApply(user: F4SUUID?,
                                  to company: F4SUUID,
                                  givenExistingPlacements existing: [F4STimelinePlacement],
                                  completion: @escaping (F4SNetworkResult<Bool>) -> Void) {
        DispatchQueue.main.async {
            let match = existing.first(where: { (existing) -> Bool in
                existing.companyUuid?.dehyphenated == company.dehyphenated
            })
            let result = F4SNetworkResult.success(match == nil)
            completion(result)
        }
    }
    
    public func checkUserCanApply(user: F4SUUID?,
                                  to company: F4SUUID,
                                  completion: @escaping (F4SNetworkResult<Bool>) -> Void) {
        placementService.getAllPlacementsForUser { [weak self] (result) in
            guard let strongSelf = self else { return }
            switch result {
            case .error(_):
                break
            case .success(let placements):
                strongSelf.checkUserCanApply(user: user,
                                             to: company,
                                             givenExistingPlacements: placements,
                                             completion: completion)
            }
        }
        
    }
    
}
