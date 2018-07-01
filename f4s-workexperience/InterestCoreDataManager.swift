//
//  InterestCoreDataManager.swift
//  f4s-workexperience
//
//  Created by Timea Tivadar on 11/28/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import Foundation
import CoreData

class InterestCoreDataManager: CoreDataBaseManager {
    class var sharedInstance: InterestCoreDataManager {
        struct Static {
            static let instance: InterestCoreDataManager = InterestCoreDataManager()
        }
        return Static.instance
    }

    func saveInterestToContext(_ interest: F4SInterest, userUuid: String) {
        InterestDB.createInManagedObjectContext(managedObjectContext, interest: interest, userUuid: userUuid)
        save()
    }

    func getInterestsForUser(userUuid: String) -> [InterestDB] {
        return InterestDB.getInterestsForUser(managedObjectContext,  userUuid: userUuid)
    }

    func getAllInterests() -> [InterestDB] {
        return InterestDB.getAllInterests(managedObjectContext)
    }

    func removeInterestWithId(interestUuid: String, userUuid: String) {
        InterestDB.removeInterestWithIdForUser(managedObjectContext,  interestUuid: interestUuid, userUuid: userUuid)
        save()
    }
}
