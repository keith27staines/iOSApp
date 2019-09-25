//
//  PlacementDBOperations.swift
//  f4s-workexperience
//
//  Created by Timea Tivadar on 11/28/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import Foundation
import WorkfinderCommon

class PlacementDBOperations {
    class var sharedInstance: PlacementDBOperations {
        struct Static {
            static let instance: PlacementDBOperations = PlacementDBOperations()
        }
        return Static.instance
    }

    func savePlacement(placement: F4SPlacement) {
        guard let userUuid = F4SUser().uuid else {
            return
        }
        PlacementCoreDataManager.sharedInstance.savePlacementToContext(placement, userUuid: userUuid)
    }
    
    func getAllPlacements() -> [F4SPlacement] {
        let placementDBData = PlacementCoreDataManager.sharedInstance.getAllPlacements()
        var placements: [F4SPlacement] = []
        for placementDB in placementDBData {
            let placement = PlacementDBOperations.sharedInstance.getPlacementFromPlacementDB(placementDB: placementDB)
            placements.append(placement)
        }
        return placements
    }

    func getPlacementForCompany(companyUuid: String) -> F4SPlacement? {
        guard let placementDB = PlacementCoreDataManager.sharedInstance.getPlacementForCompany(companyUuid: companyUuid) else {
            return nil
        }
        return PlacementDBOperations.sharedInstance.getPlacementFromPlacementDB(placementDB: placementDB)
    }

    func getPlacementWithUuid(placementUuid: String) -> F4SPlacement? {
        guard
            let placementDB = PlacementCoreDataManager.sharedInstance.getPlacement(placementUuid: placementUuid) else {
            return nil
        }
        return PlacementDBOperations.sharedInstance.getPlacementFromPlacementDB(placementDB: placementDB)
    }

    fileprivate func getPlacementFromPlacementDB(placementDB: PlacementDB) -> F4SPlacement {
        var placement: F4SPlacement = F4SPlacement()
        if let placementUuid = placementDB.placementUuid {
            placement.placementUuid = placementUuid
        }
        if let companyUuid = placementDB.companyUuid {
            placement.companyUuid = companyUuid
        }
        if let placementStatus = placementDB.status {
            placement.status = F4SPlacementState(rawValue: placementStatus)
            if placement.status == nil {
                if placementStatus == "inProgress" {
                    placement.status = F4SPlacementState.inProgress
                }
            }
        }
        return placement
    }
}
