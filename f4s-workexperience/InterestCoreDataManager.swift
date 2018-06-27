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
        guard let managedObjectCont = self.managedObjectContext else {
            return
        }
        InterestDB.createInManagedObjectContext(managedObjectCont, interest: interest, userUuid: userUuid)
        save()
    }

    func getInterestsForUser(userUuid: String) -> [InterestDB] {
        guard let managedObjectCont = self.managedObjectContext else {
            return []
        }
        return InterestDB.getInterestsForUser(managedObjectCont, userUuid: userUuid)
    }

    func getAllInterests() -> [InterestDB] {
        guard let managedObjectCont = self.managedObjectContext else {
            return []
        }
        return InterestDB.getAllInterests(managedObjectCont)
    }

    func removeInterestWithId(interestUuid: String, userUuid: String) {
        guard let managedObjectCont = self.managedObjectContext else {
            return
        }
        InterestDB.removeInterestWithIdForUser(managedObjectCont, interestUuid: interestUuid, userUuid: userUuid)
        save()
    }
}
