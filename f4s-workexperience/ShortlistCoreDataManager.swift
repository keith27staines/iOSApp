//
//  ShortlistCoreDataManager.swift
//  f4s-workexperience
//
//  Created by Timea Tivadar on 2/8/17.
//  Copyright © 2017 freshbyte. All rights reserved.
//

import Foundation
import WorkfinderCommon
import CoreData

class ShortlistCoreDataManager: CoreDataBaseManager {
    class var sharedInstance: ShortlistCoreDataManager {
        struct Static {
            static let instance: ShortlistCoreDataManager = ShortlistCoreDataManager()
        }
        return Static.instance
    }

    func saveShortlistToContext(_ shortlist: Shortlist) {
        ShortlistDB.createInManagedObjectContext(managedObjectContext,  shortlist: shortlist)
        save()
    }

    func getAllShortlists() -> [ShortlistDB] {
        return ShortlistDB.getAllShortlists(managedObjectContext)
    }

    func removeShortlistWithId(shortlistUuid: String) {
        ShortlistDB.removeInterestWithIdForUser(managedObjectContext,  uuid: shortlistUuid)
        save()
    }
}
