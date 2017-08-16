//
//  InterestDB.swift
//  f4s-workexperience
//
//  Created by Timea Tivadar on 11/28/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import Foundation
import CoreData

@objc(InterestDB)
class InterestDB: NSManagedObject {

    @NSManaged var id: Int64
    @NSManaged var uuid: String?
    @NSManaged var name: String?
    @NSManaged var userUuid: String?

    @discardableResult
    class func createInManagedObjectContext(_ moc: NSManagedObjectContext, interest: Interest, userUuid: String) -> InterestDB? {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest<NSFetchRequestResult>(entityName: "Interest")

        let predicate = NSPredicate(format: "userUuid == %@ && uuid == %@", userUuid, interest.uuid)
        fetchRequest.predicate = predicate
        guard let fetchResult = (try? moc.fetch(fetchRequest)) as? [InterestDB] else {
            return nil
        }

        if fetchResult.count == 0 {
            guard let newItem = NSEntityDescription.insertNewObject(forEntityName: "Interest", into: moc) as? InterestDB else {
                return nil
            }
            newItem.uuid = interest.uuid
            newItem.name = interest.name
            newItem.userUuid = userUuid
            newItem.id = interest.id
            return newItem
        } else {
            fetchResult[0].id = interest.id
            fetchResult[0].uuid = interest.uuid
            fetchResult[0].name = interest.name
            fetchResult[0].userUuid = userUuid
            return fetchResult[0]
        }
    }

    class func getInterestsForUser(_ moc: NSManagedObjectContext, userUuid: String) -> [InterestDB] {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest<NSFetchRequestResult>(entityName: "Interest")

        let predicate = NSPredicate(format: "userUuid == %@", userUuid)
        fetchRequest.predicate = predicate

        guard let fetchResult = (try? moc.fetch(fetchRequest)) as? [InterestDB], !fetchResult.isEmpty else {
            return []
        }

        return fetchResult
    }

    class func getAllInterests(_ moc: NSManagedObjectContext) -> [InterestDB] {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest<NSFetchRequestResult>(entityName: "Interest")

        guard let fetchResult = (try? moc.fetch(fetchRequest)) as? [InterestDB], !fetchResult.isEmpty else {
            return []
        }

        return fetchResult
    }

    class func removeInterestWithIdForUser(_ moc: NSManagedObjectContext, interestUuid: String, userUuid: String) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest<NSFetchRequestResult>(entityName: "Interest")

        let predicate = NSPredicate(format: "userUuid == %@ && uuid == %@", userUuid, interestUuid)
        fetchRequest.predicate = predicate

        guard let fetchResult = (try? moc.fetch(fetchRequest)) as? [InterestDB], !fetchResult.isEmpty else {
            return
        }
        moc.delete(fetchResult[0])
    }
}
