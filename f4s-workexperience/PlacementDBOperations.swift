//
//  PlacementDBOperations.swift
//  f4s-workexperience
//
//  Created by Timea Tivadar on 11/28/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import Foundation
import KeychainSwift

class PlacementDBOperations {
    class var sharedInstance: PlacementDBOperations {
        struct Static {
            static let instance: PlacementDBOperations = PlacementDBOperations()
        }
        return Static.instance
    }

    func savePlacement(placement: Placement) {
        let keychain = KeychainSwift()
        guard let userUuid = keychain.get(UserDefaultsKeys.userUuid) else {
            return
        }
        PlacementCoreDataManager.sharedInstance.savePlacementToContext(placement, userUuid: userUuid)
    }

    func getPlacementsForCurrentUser() -> [Placement] {
        let keychain = KeychainSwift()
        guard let userUuid = keychain.get(UserDefaultsKeys.userUuid) else {
            return []
        }
        let placementDBData = PlacementCoreDataManager.sharedInstance.getPlacementsForUser(userUuid: userUuid)
        var placements: [Placement] = []
        for placementDB in placementDBData {
            let placement = PlacementDBOperations.sharedInstance.getPlacementFromPlacementDB(placementDB: placementDB)
            placements.append(placement)
        }
        return placements
    }

    func getPlacementsForCurrentUserAndCompany(companyUuid: String) -> Placement? {
        let keychain = KeychainSwift()
        guard let userUuid = keychain.get(UserDefaultsKeys.userUuid),
            let placementDB = PlacementCoreDataManager.sharedInstance.getPlacementsForUserAndCompany(userUuid: userUuid, companyUuid: companyUuid) else {
            return nil
        }
        return PlacementDBOperations.sharedInstance.getPlacementFromPlacementDB(placementDB: placementDB)
    }

    func getAllPlacements() -> [Placement] {
        let placementDBData = PlacementCoreDataManager.sharedInstance.getAllPlacements()
        var placements: [Placement] = []
        for placementDB in placementDBData {
            let placement = PlacementDBOperations.sharedInstance.getPlacementFromPlacementDB(placementDB: placementDB)
            placements.append(placement)
        }
        return placements
    }

    func getInProgressPlacementsForCurrentUser() -> Placement? {
        let keychain = KeychainSwift()
        guard let userUuid = keychain.get(UserDefaultsKeys.userUuid),
            let placementDB = PlacementCoreDataManager.sharedInstance.getInProgressPlacementsForUser(userUuid: userUuid) else {
            return nil
        }
        return PlacementDBOperations.sharedInstance.getPlacementFromPlacementDB(placementDB: placementDB)
    }

    func removePlacementWithId(placementUuid: String) {
        let keychain = KeychainSwift()
        if let userUuid = keychain.get(UserDefaultsKeys.userUuid) {
            PlacementCoreDataManager.sharedInstance.removePlacementWithId(placementUuid: placementUuid, userUuid: userUuid)
        }
    }

    func getPlacementWithUuid(placementUuid: String) -> Placement? {
        let keychain = KeychainSwift()
        guard let userUuid = keychain.get(UserDefaultsKeys.userUuid),
            let placementDB = PlacementCoreDataManager.sharedInstance.getPlacementForUserAndPlacementUuid(userUuid: userUuid, placementUuid: placementUuid) else {
            return nil
        }
        return PlacementDBOperations.sharedInstance.getPlacementFromPlacementDB(placementDB: placementDB)
    }

    fileprivate func getPlacementFromPlacementDB(placementDB: PlacementDB) -> Placement {
        var placement: Placement = Placement()
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
