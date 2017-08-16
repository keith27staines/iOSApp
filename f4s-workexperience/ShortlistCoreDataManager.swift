//
//  ShortlistCoreDataManager.swift
//  f4s-workexperience
//
//  Created by Timea Tivadar on 2/8/17.
//  Copyright © 2017 freshbyte. All rights reserved.
//

import Foundation
import CoreData

class ShortlistCoreDataManager: CoreDataBaseManager {
    class var sharedInstance: ShortlistCoreDataManager {
        struct Static {
            static let instance: ShortlistCoreDataManager = ShortlistCoreDataManager()
        }
        return Static.instance
    }

    func saveShortlistToContext(_ shortlist: Shortlist, userUuid: String) {
        guard let managedObjectCont = self.managedObjectContext else {
            return
        }
        ShortlistDB.createInManagedObjectContext(managedObjectCont, shortlist: shortlist, userUuid: userUuid)
        save()
    }

    func getShortlistForUser(userUuid: String) -> [ShortlistDB] {
        guard let managedObjectCont = self.managedObjectContext else {
            return []
        }
        return ShortlistDB.getShortlistForUser(managedObjectCont, userUuid: userUuid)
    }

    func getAllShortlists() -> [ShortlistDB] {
        guard let managedObjectCont = self.managedObjectContext else {
            return []
        }
        return ShortlistDB.getAllShortlists(managedObjectCont)
    }

    func removeShortlistWithId(shortlistUuid: String, userUuid: String) {
        guard let managedObjectCont = self.managedObjectContext else {
            return
        }
        ShortlistDB.removeInterestWithIdForUser(managedObjectCont, uuid: shortlistUuid, userUuid: userUuid)
        save()
    }
}
