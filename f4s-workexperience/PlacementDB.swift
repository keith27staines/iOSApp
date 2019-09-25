//
//  PlacementDB.swift
//  f4s-workexperience
//
//  Created by Timea Tivadar on 11/28/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import Foundation
import CoreData
import WorkfinderCommon

@objc(PlacementDB)
class PlacementDB: NSManagedObject {

    @NSManaged var companyUuid: String?
    @NSManaged var placementUuid: String?
    @NSManaged var status: String?
    @NSManaged var userUuid: String?

    @discardableResult
    class func createInManagedObjectContext(_ moc: NSManagedObjectContext, placement: F4SPlacement, userUuid: String) -> PlacementDB? {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest<NSFetchRequestResult>(entityName: "Placement")

        let predicate = NSPredicate(format: "userUuid == %@ && companyUuid == %@", userUuid, placement.companyUuid!)
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
            newItem.status = ""
            if let status = placement.status {
                newItem.status = status.rawValue
            }
            return newItem
        } else {
            fetchResult[0].companyUuid = placement.companyUuid
            fetchResult[0].placementUuid = placement.placementUuid
            fetchResult[0].userUuid = userUuid
            fetchResult[0].status = placement.status!.rawValue
            return fetchResult[0]
        }
    }
    
    class func getAllPlacements(_ moc: NSManagedObjectContext) -> [PlacementDB] {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest<NSFetchRequestResult>(entityName: "Placement")

        guard let fetchResult = (try? moc.fetch(fetchRequest)) as? [PlacementDB], !fetchResult.isEmpty else {
            return []
        }

        return fetchResult
    }

    class func getPlacementForCompany(_ moc: NSManagedObjectContext, companyUuid: String) -> PlacementDB? {
        let placements = getAllPlacements(moc)
        let firstPlacement = placements.filter({ (placement) -> Bool in
            placement.companyUuid?.dehyphenated == companyUuid
        }).first
        return firstPlacement
    }

    class func getPlacement(_ moc: NSManagedObjectContext, placementUuid: String) -> PlacementDB? {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest<NSFetchRequestResult>(entityName: "Placement")

        let predicate = NSPredicate(format: "placementUuid == %@", placementUuid)
        fetchRequest.predicate = predicate

        guard let fetchResult = (try? moc.fetch(fetchRequest)) as? [PlacementDB], !fetchResult.isEmpty else {
            return nil
        }

        return fetchResult[0]
    }
}
