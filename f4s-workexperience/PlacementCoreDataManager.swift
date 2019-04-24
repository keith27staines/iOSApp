//
//  PlacementCoreDataManager.swift
//  f4s-workexperience
//
//  Created by Timea Tivadar on 11/28/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import Foundation
import CoreData
import WorkfinderCommon

class PlacementCoreDataManager: CoreDataBaseManager {
    class var sharedInstance: PlacementCoreDataManager {
        struct Static {
            static let instance: PlacementCoreDataManager = PlacementCoreDataManager()
        }
        return Static.instance
    }

    func savePlacementToContext(_ placement: F4SPlacement, userUuid: String) {
        PlacementDB.createInManagedObjectContext(managedObjectContext,  placement: placement, userUuid: userUuid)
        save()
    }

    func getPlacementsForUser(userUuid: String) -> [PlacementDB] {
        return PlacementDB.getPlacementsForUser(managedObjectContext,  userUuid: userUuid)
    }

    func getPlacementForCompany(companyUuid: String) -> PlacementDB? {
        return PlacementDB.getPlacementForCompany(managedObjectContext, companyUuid: companyUuid)
    }

    func getAllPlacements() -> [PlacementDB] {
        return PlacementDB.getAllPlacements(managedObjectContext)
    }

    func getPlacementForUserAndPlacementUuid(userUuid: String, placementUuid: String) -> PlacementDB? {
        return PlacementDB.getPlacementsWithUuid(managedObjectContext,  userUuid: userUuid, placementUuid: placementUuid)
    }
}
