//
//  InterestDBOperations.swift
//  f4s-workexperience
//
//  Created by Timea Tivadar on 11/28/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import Foundation
import KeychainSwift

class InterestDBOperations {
    class var sharedInstance: InterestDBOperations {
        struct Static {
            static let instance: InterestDBOperations = InterestDBOperations()
        }
        return Static.instance
    }

    func saveInterest(interest: Interest) {
        let keychain = KeychainSwift()
        if let userUuid = keychain.get(UserDefaultsKeys.userUuid) {
            InterestCoreDataManager.sharedInstance.saveInterestToContext(interest, userUuid: userUuid)
        }
    }

    func interestsForCurrentUser() -> [Interest] {
        let keychain = KeychainSwift()
        guard let userUuid = keychain.get(UserDefaultsKeys.userUuid) else {
            return []
        }
        let interestDBData = InterestCoreDataManager.sharedInstance.getInterestsForUser(userUuid: userUuid)
        var interests: [Interest] = []
        for interestDB in interestDBData {
            let interest = InterestDBOperations.sharedInstance.getInterestFromInterestDB(interestDB: interestDB)
            interests.append(interest)
        }
        return interests
    }

    func getAllInterests() -> [Interest] {
        let interestDBData = InterestCoreDataManager.sharedInstance.getAllInterests()
        var interests: [Interest] = []
        for interestDB in interestDBData {
            let interest = InterestDBOperations.sharedInstance.getInterestFromInterestDB(interestDB: interestDB)
            interests.append(interest)
        }
        return interests
    }

    func removeInterestWithId(interestUuid: String) {
        let keychain = KeychainSwift()
        guard let userUuid = keychain.get(UserDefaultsKeys.userUuid) else {
            return
        }
        InterestCoreDataManager.sharedInstance.removeInterestWithId(interestUuid: interestUuid, userUuid: userUuid)
    }

    fileprivate func getInterestFromInterestDB(interestDB: InterestDB) -> Interest {
        var interest: Interest = Interest(id: interestDB.id)
        if let uuid = interestDB.uuid {
            interest.uuid = uuid
        }
        if let name = interestDB.name {
            interest.name = name
        }
        return interest
    }
}
