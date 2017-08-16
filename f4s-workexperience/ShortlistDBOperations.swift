//
//  ShortlistDBOperations.swift
//  f4s-workexperience
//
//  Created by Timea Tivadar on 2/8/17.
//  Copyright © 2017 freshbyte. All rights reserved.
//

import Foundation
import KeychainSwift

class ShortlistDBOperations {
    class var sharedInstance: ShortlistDBOperations {
        struct Static {
            static let instance: ShortlistDBOperations = ShortlistDBOperations()
        }
        return Static.instance
    }

    func saveShortlist(shortlist: Shortlist) {
        let keychain = KeychainSwift()
        if let userUuid = keychain.get(UserDefaultsKeys.userUuid) {
            ShortlistCoreDataManager.sharedInstance.saveShortlistToContext(shortlist, userUuid: userUuid)
        }
    }

    func getShortlistForCurrentUser() -> [Shortlist] {
        let keychain = KeychainSwift()
        guard let userUuid = keychain.get(UserDefaultsKeys.userUuid) else {
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

    func getAllShortlists() -> [Shortlist] {
        let shortlistDBData = ShortlistCoreDataManager.sharedInstance.getAllShortlists()
        var shortlists: [Shortlist] = []
        for shortlistDB in shortlistDBData {
            let shortlist = ShortlistDBOperations.sharedInstance.getShortlistFromShortlistDB(shortlistDB: shortlistDB)
            shortlists.append(shortlist)
        }
        return shortlists
    }

    func removeShortlistWithId(shortlistUuid: String) {
        let keychain = KeychainSwift()
        guard let userUuid = keychain.get(UserDefaultsKeys.userUuid) else {
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
