//
//  ShortlistDBOperations.swift
//  f4s-workexperience
//
//  Created by Timea Tivadar on 2/8/17.
//  Copyright © 2017 freshbyte. All rights reserved.
//

import Foundation

class ShortlistDBOperations {
    class var sharedInstance: ShortlistDBOperations {
        struct Static {
            static let instance: ShortlistDBOperations = ShortlistDBOperations()
        }
        return Static.instance
    }

    func saveShortlist(shortlist: Shortlist) {
        if let userUuid = F4SUser().uuid {
            ShortlistCoreDataManager.sharedInstance.saveShortlistToContext(shortlist, userUuid: userUuid)
        }
    }

    func getShortlistForCurrentUser() -> [Shortlist] {
        guard let userUuid = F4SUser().uuid else {
            return []
        }
        let shortlistDBData = ShortlistCoreDataManager.sharedInstance.getShortlistForUser(userUuid: userUuid)
        var shortlists: [Shortlist] = []
        for shortlistDB in shortlistDBData {
            let shortlist = ShortlistDBOperations.sharedInstance.getShortlistFromShortlistDB(shortlistDB: shortlistDB)
            shortlists.append(shortlist)
        }
        return shortlists
    }

    func removeShortlistWithId(shortlistUuid: String) {
        guard let userUuid = F4SUser().uuid else {
            return
        }
        ShortlistCoreDataManager.sharedInstance.removeShortlistWithId(shortlistUuid: shortlistUuid, userUuid: userUuid)
    }

    fileprivate func getShortlistFromShortlistDB(shortlistDB: ShortlistDB) -> Shortlist {
        var shortlist: Shortlist = Shortlist()
        if let uuid = shortlistDB.uuid {
            shortlist.uuid = uuid
        }
        if let companyUuid = shortlistDB.companyUuid {
            shortlist.companyUuid = companyUuid
        }
        if let date = shortlistDB.date {
            shortlist.date = date
        }
        return shortlist
    }
}
