//
//  PlacementCoreDataManager.swift
//  f4s-workexperience
//
//  Created by Timea Tivadar on 11/28/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import Foundation
import CoreData

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

    func getPlacementsForUserAndCompany(userUuid: String, companyUuid: String) -> PlacementDB? {
        return PlacementDB.getPlacementsForUserAndCompany(managedObjectContext,  userUuid: userUuid, companyUuid: companyUuid)
    }

    func getAllPlacements() -> [PlacementDB] {
        return PlacementDB.getAllPlacements(managedObjectContext)
    }

    func getInProgressPlacementsForUser(userUuid: String) -> PlacementDB? {
        return PlacementDB.getInProgressPlacementsForUser(managedObjectContext,  userUuid: userUuid)
    }

    func removePlacementWithId(placementUuid: String, userUuid: String) {
        PlacementDB.removePlacementWithIdForUser(managedObjectContext,  placementUuid: placementUuid, userUuid: userUuid)
        save()
    }

    func getPlacementForUserAndPlacementUuid(userUuid: String, placementUuid: String) -> PlacementDB? {
        return PlacementDB.getPlacementsWithUuid(managedObjectContext,  userUuid: userUuid, placementUuid: placementUuid)
    }
}
