//
//  UserInfoDB.swift
//  f4s-workexperience
//
//  Created by Sergiu Simon on 16/12/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import Foundation
import CoreData

@objc(UserInfoDB)
class UserInfoDB: NSManagedObject {

    @NSManaged var userUuid: String?
    @NSManaged var email: String?
    @NSManaged var placementUuid: String?
    @NSManaged var firstName: String?
    @NSManaged var lastName: String?
    @NSManaged var consenterEmail: String?
    @NSManaged var requiresConsent: Bool
    @NSManaged var dateOfBirth: String?

    @discardableResult
    class func createInManagedObjectContext(_ moc: NSManagedObjectContext, userInfo: F4SUser, userUuid: String) -> UserInfoDB? {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest<NSFetchRequestResult>(entityName: "User")

        let predicate = NSPredicate(format: "userUuid == %@", userUuid)
        fetchRequest.predicate = predicate
        guard let fetchResult = (try? moc.fetch(fetchRequest)) as? [UserInfoDB] else {
            return nil
        }

        if fetchResult.count == 0 {
            guard let newItem = NSEntityDescription.insertNewObject(forEntityName: "User", into: moc) as? UserInfoDB else {
                return nil
            }
            newItem.email = userInfo.email
            newItem.firstName = userInfo.firstName
            newItem.lastName = userInfo.lastName
            newItem.consenterEmail = userInfo.parentEmail
            newItem.dateOfBirth = userInfo.dateOfBirth?.dateToStringRfc3339()
            newItem.requiresConsent = userInfo.requiresConsent ?? false
            newItem.placementUuid = userInfo.placementUuid
            newItem.userUuid = userUuid

            return newItem
        } else {
            fetchResult[0].firstName = userInfo.firstName
            fetchResult[0].lastName = userInfo.lastName
            fetchResult[0].email = userInfo.email
            fetchResult[0].consenterEmail = userInfo.parentEmail
            fetchResult[0].dateOfBirth = userInfo.dateOfBirth?.dateToStringRfc3339()
            fetchResult[0].requiresConsent = userInfo.requiresConsent ?? false
            fetchResult[0].placementUuid = userInfo.placementUuid
            fetchResult[0].userUuid = userUuid

            return fetchResult[0]
        }
    }

    class func getUserInfo(_ moc: NSManagedObjectContext, userUuid: String) -> UserInfoDB? {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest<NSFetchRequestResult>(entityName: "User")

        //let predicate = NSPredicate(format: "userUuid == %@", userUuid)
        let predicate = NSPredicate(value: true)
        fetchRequest.predicate = predicate

        guard let fetchResult = (try? moc.fetch(fetchRequest)) as? [UserInfoDB], !fetchResult.isEmpty else {
            return nil
        }

        return fetchResult[0]
    }
}
