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
        ShortlistDB.createInManagedObjectContext(managedObjectContext,  shortlist: shortlist, userUuid: userUuid)
        save()
    }

    func getShortlistForUser(userUuid: String) -> [ShortlistDB] {
        return ShortlistDB.getShortlistForUser(managedObjectContext,  userUuid: userUuid)
    }

    func getAllShortlists() -> [ShortlistDB] {
        return ShortlistDB.getAllShortlists(managedObjectContext)
    }

    func removeShortlistWithId(shortlistUuid: String, userUuid: String) {
        ShortlistDB.removeInterestWithIdForUser(managedObjectContext,  uuid: shortlistUuid, userUuid: userUuid)
        save()
    }
}
