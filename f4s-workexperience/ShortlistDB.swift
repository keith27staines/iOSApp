//
//  ShortlistDB.swift
//  f4s-workexperience
//
//  Created by Timea Tivadar on 2/8/17.
//  Copyright © 2017 freshbyte. All rights reserved.
//

import Foundation
import WorkfinderCommon
import CoreData

@objc(ShortlistDB)
class ShortlistDB: NSManagedObject {

    @NSManaged var companyUuid: String?
    @NSManaged var userUuid: String?
    @NSManaged var uuid: String?
    @NSManaged var date: Date?

    @discardableResult
    class func createInManagedObjectContext(_ moc: NSManagedObjectContext, shortlist: Shortlist, userUuid: String) -> ShortlistDB? {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest<NSFetchRequestResult>(entityName: "Shortlist")

        let predicate = NSPredicate(format: "userUuid == %@ && uuid == %@", userUuid, shortlist.uuid)
        fetchRequest.predicate = predicate
        guard let fetchResult = (try? moc.fetch(fetchRequest)) as? [ShortlistDB] else {
            return nil
        }

        if fetchResult.count == 0 {
            guard let newItem = NSEntityDescription.insertNewObject(forEntityName: "Shortlist", into: moc) as? ShortlistDB else {
                return nil
            }
            newItem.uuid = shortlist.uuid
            newItem.companyUuid = shortlist.companyUuid
            newItem.userUuid = userUuid
            newItem.date = shortlist.date
            return newItem
        } else {
            fetchResult[0].uuid = shortlist.uuid
            fetchResult[0].companyUuid = shortlist.companyUuid
            fetchResult[0].userUuid = userUuid
            fetchResult[0].date = shortlist.date
            return fetchResult[0]
        }
    }

    class func getShortlistForUser(_ moc: NSManagedObjectContext, userUuid: String) -> [ShortlistDB] {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest<NSFetchRequestResult>(entityName: "Shortlist")

        let predicate = NSPredicate(format: "userUuid == %@", userUuid)
        fetchRequest.predicate = predicate

        guard let fetchResult = (try? moc.fetch(fetchRequest)) as? [ShortlistDB], !fetchResult.isEmpty else {
            return []
        }

        return fetchResult
    }

    class func getAllShortlists(_ moc: NSManagedObjectContext) -> [ShortlistDB] {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest<NSFetchRequestResult>(entityName: "Shortlist")

        guard let fetchResult = (try? moc.fetch(fetchRequest)) as? [ShortlistDB], !fetchResult.isEmpty else {
            return []
        }

        return fetchResult
    }

    class func removeInterestWithIdForUser(_ moc: NSManagedObjectContext, uuid: String, userUuid: String) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest<NSFetchRequestResult>(entityName: "Shortlist")

        let predicate = NSPredicate(format: "userUuid == %@ && uuid == %@", userUuid, uuid)
        fetchRequest.predicate = predicate

        guard let fetchResult = (try? moc.fetch(fetchRequest)) as? [ShortlistDB], !fetchResult.isEmpty else {
            return
        }
        moc.delete(fetchResult[0])
    }
}
