//
//  PlacementDBOperations.swift
//  f4s-workexperience
//
//  Created by Timea Tivadar on 11/28/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import Foundation

class PlacementDBOperations {
    class var sharedInstance: PlacementDBOperations {
        struct Static {
            static let instance: PlacementDBOperations = PlacementDBOperations()
        }
        return Static.instance
    }

    func savePlacement(placement: F4SPlacement) {
        guard let userUuid = F4SUser.userUuidFromKeychain else {
            return
        }
        PlacementCoreDataManager.sharedInstance.savePlacementToContext(placement, userUuid: userUuid)
    }

    func getPlacementsForCurrentUser() -> [F4SPlacement] {
        guard let userUuid = F4SUser.userUuidFromKeychain else {
            return []
        }
        let placementDBData = PlacementCoreDataManager.sharedInstance.getPlacementsForUser(userUuid: userUuid)
        var placements: [F4SPlacement] = []
        for placementDB in placementDBData {
            let placement = PlacementDBOperations.sharedInstance.getPlacementFromPlacementDB(placementDB: placementDB)
            placements.append(placement)
        }
        return placements
    }

    func getPlacementsForCurrentUserAndCompany(companyUuid: String) -> F4SPlacement? {
        guard let userUuid = F4SUser.userUuidFromKeychain,
            let placementDB = PlacementCoreDataManager.sharedInstance.getPlacementsForUserAndCompany(userUuid: userUuid, companyUuid: companyUuid) else {
            return nil
        }
        return PlacementDBOperations.sharedInstance.getPlacementFromPlacementDB(placementDB: placementDB)
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

    func getInProgressPlacementsForCurrentUser() -> F4SPlacement? {
        guard let userUuid = F4SUser.userUuidFromKeychain,
            let placementDB = PlacementCoreDataManager.sharedInstance.getInProgressPlacementsForUser(userUuid: userUuid) else {
            return nil
        }
        return PlacementDBOperations.sharedInstance.getPlacementFromPlacementDB(placementDB: placementDB)
    }

    func removePlacementWithId(placementUuid: String) {
        if let userUuid = F4SUser.userUuidFromKeychain {
            PlacementCoreDataManager.sharedInstance.removePlacementWithId(placementUuid: placementUuid, userUuid: userUuid)
        }
    }

    func getPlacementWithUuid(placementUuid: String) -> F4SPlacement? {
        guard let userUuid = F4SUser.userUuidFromKeychain,
            let placementDB = PlacementCoreDataManager.sharedInstance.getPlacementForUserAndPlacementUuid(userUuid: userUuid, placementUuid: placementUuid) else {
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
            switch placementStatus {
            case "inProgress":
                placement.status = .inProgress
                break
            default:
                // applied
                placement.status = .applied
                break
            }
        }
        return placement
    }
}
