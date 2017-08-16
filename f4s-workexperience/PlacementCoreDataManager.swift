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

    func savePlacementToContext(_ placement: Placement, userUuid: String) {
        guard let managedObjectCont = self.managedObjectContext else {
            return
        }
        PlacementDB.createInManagedObjectContext(managedObjectCont, placement: placement, userUuid: userUuid)
        save()
    }

    func getPlacementsForUser(userUuid: String) -> [PlacementDB] {
        guard let managedObjectCont = self.managedObjectContext else {
            return []
        }
        return PlacementDB.getPlacementsForUser(managedObjectCont, userUuid: userUuid)
    }

    func getPlacementsForUserAndCompany(userUuid: String, companyUuid: String) -> PlacementDB? {
        guard let managedObjectCont = self.managedObjectContext else {
            return nil
        }
        return PlacementDB.getPlacementsForUserAndCompany(managedObjectCont, userUuid: userUuid, companyUuid: companyUuid)
    }

    func getAllPlacements() -> [PlacementDB] {
        guard let managedObjectCont = self.managedObjectContext else {
            return []
        }
        return PlacementDB.getAllPlacements(managedObjectCont)
    }

    func getInProgressPlacementsForUser(userUuid: String) -> PlacementDB? {
        guard let managedObjectCont = self.managedObjectContext else {
            return nil
        }
        return PlacementDB.getInProgressPlacementsForUser(managedObjectCont, userUuid: userUuid)
    }

    func removePlacementWithId(placementUuid: String, userUuid: String) {
        guard let managedObjectCont = self.managedObjectContext else {
            return
        }
        PlacementDB.removePlacementWithIdForUser(managedObjectCont, placementUuid: placementUuid, userUuid: userUuid)
        save()
    }

    func getPlacementForUserAndPlacementUuid(userUuid: String, placementUuid: String) -> PlacementDB? {
        guard let managedObjectCont = self.managedObjectContext else {
            return nil
        }
        return PlacementDB.getPlacementsWithUuid(managedObjectCont, userUuid: userUuid, placementUuid: placementUuid)
    }
}
