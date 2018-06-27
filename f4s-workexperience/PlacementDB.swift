//
//  PlacementDB.swift
//  f4s-workexperience
//
//  Created by Timea Tivadar on 11/28/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import Foundation
import CoreData

@objc(PlacementDB)
class PlacementDB: NSManagedObject {

    @NSManaged var companyUuid: String?
    @NSManaged var placementUuid: String?
    @NSManaged var status: String?
    @NSManaged var userUuid: String?

    @discardableResult
    class func createInManagedObjectContext(_ moc: NSManagedObjectContext, placement: F4SPlacement, userUuid: String) -> PlacementDB? {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest<NSFetchRequestResult>(entityName: "Placement")

        let predicate = NSPredicate(format: "userUuid == %@ && companyUuid == %@", userUuid, placement.companyUuid)
        fetchRequest.predicate = predicate
        guard let fetchResult = (try? moc.fetch(fetchRequest)) as? [PlacementDB] else {
            return nil
        }

        if fetchResult.count == 0 {
            guard let newItem = NSEntityDescription.insertNewObject(forEntityName: "Placement", into: moc) as? PlacementDB else {
                return nil
            }
            newItem.companyUuid = placement.companyUuid
            newItem.placementUuid = placement.placementUuid
            newItem.userUuid = userUuid

            switch placement.status
            {
            case .inProgress:
                newItem.status = "inProgress"
                break
            default:
                // applied
                newItem.status = "applied"
                break
            }

            return newItem
        } else {
            fetchResult[0].companyUuid = placement.companyUuid
            fetchResult[0].placementUuid = placement.placementUuid
            fetchResult[0].userUuid = userUuid

            switch placement.status
            {
            case .inProgress:
                fetchResult[0].status = "inProgress"
                break
            default:
                // applied
                fetchResult[0].status = "applied"
                break
            }

            return fetchResult[0]
        }
    }

    class func getPlacementsForUser(_ moc: NSManagedObjectContext, userUuid: String) -> [PlacementDB] {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest<NSFetchRequestResult>(entityName: "Placement")

        let predicate = NSPredicate(format: "userUuid == %@", userUuid)
        fetchRequest.predicate = predicate

        guard let fetchResult = (try? moc.fetch(fetchRequest)) as? [PlacementDB], !fetchResult.isEmpty else {
            return []
        }

        return fetchResult
    }

    class func getPlacementsForUserAndCompany(_ moc: NSManagedObjectContext, userUuid: String, companyUuid: String) -> PlacementDB? {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest<NSFetchRequestResult>(entityName: "Placement")

        let predicate = NSPredicate(format: "userUuid == %@ && companyUuid == %@", userUuid, companyUuid)
        fetchRequest.predicate = predicate

        guard let fetchResult = (try? moc.fetch(fetchRequest)) as? [PlacementDB], !fetchResult.isEmpty else {
            return nil
        }

        return fetchResult[0]
    }

    class func getInProgressPlacementsForUser(_ moc: NSManagedObjectContext, userUuid: String) -> PlacementDB? {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest<NSFetchRequestResult>(entityName: "Placement")

        let predicate = NSPredicate(format: "userUuid == %@ && status == %@", userUuid, "inProgress")
        fetchRequest.predicate = predicate

        guard let fetchResult = (try? moc.fetch(fetchRequest)) as? [PlacementDB], !fetchResult.isEmpty else {
            return nil
        }

        return fetchResult[0]
    }

    class func getAllPlacements(_ moc: NSManagedObjectContext) -> [PlacementDB] {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest<NSFetchRequestResult>(entityName: "Placement")

        guard let fetchResult = (try? moc.fetch(fetchRequest)) as? [PlacementDB], !fetchResult.isEmpty else {
            return []
        }

        return fetchResult
    }

    class func removePlacementWithIdForUser(_ moc: NSManagedObjectContext, placementUuid: String, userUuid: String) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest<NSFetchRequestResult>(entityName: "Placement")

        let predicate = NSPredicate(format: "userUuid == %@ && uuid == %@", userUuid, placementUuid)
        fetchRequest.predicate = predicate

        guard let fetchResult = (try? moc.fetch(fetchRequest)) as? [PlacementDB], !fetchResult.isEmpty else {
            return
        }
        moc.delete(fetchResult[0])
    }

    class func getPlacementsWithUuid(_ moc: NSManagedObjectContext, userUuid: String, placementUuid: String) -> PlacementDB? {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest<NSFetchRequestResult>(entityName: "Placement")

        let predicate = NSPredicate(format: "userUuid == %@ && placementUuid == %@", userUuid, placementUuid)
        fetchRequest.predicate = predicate

        guard let fetchResult = (try? moc.fetch(fetchRequest)) as? [PlacementDB], !fetchResult.isEmpty else {
            return nil
        }

        return fetchResult[0]
    }
}
