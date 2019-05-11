//
//  UserInfoDB.swift
//  f4s-workexperience
//
//  Created by Sergiu Simon on 16/12/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import Foundation
import CoreData
import WorkfinderCommon

@objc(UserInfoDB)
class UserInfoDB: NSManagedObject, UserData {
    
    @NSManaged var userUuid: String?
    @NSManaged var email: String?
    @NSManaged var placementUuid: String?
    @NSManaged var firstName: String?
    @NSManaged var lastName: String?
    @NSManaged var consenterEmail: String?
    @NSManaged var requiresConsent: Bool
    @NSManaged var dateOfBirth: String?
    
    class func getUserInfo(_ moc: NSManagedObjectContext, userUuid: String) -> UserInfoDB? {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        
        let predicate = NSPredicate(format: "userUuid == %@", userUuid)
        fetchRequest.predicate = predicate
        
        guard let fetchResult = (try? moc.fetch(fetchRequest)) as? [UserInfoDB], !fetchResult.isEmpty else {
            return nil
        }
        
        return fetchResult[0]
    }
    
    class func deleteUser(_ moc: NSManagedObjectContext) throws {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try moc.persistentStoreCoordinator?.execute(deleteRequest, with: moc)
    }
}
