//
//  InterestDBOperations.swift
//  f4s-workexperience
//
//  Created by Timea Tivadar on 11/28/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import Foundation

class InterestDBOperations {
    class var sharedInstance: InterestDBOperations {
        struct Static {
            static let instance: InterestDBOperations = InterestDBOperations()
        }
        return Static.instance
    }

    func saveInterest(_ interest: F4SInterest) {
        if let userUuid = F4SUser.userUuidFromKeychain {
            InterestCoreDataManager.sharedInstance.saveInterestToContext(interest, userUuid: userUuid)
        }
    }

    func interestsForCurrentUser() -> F4SInterestSet {
        guard let userUuid = F4SUser.userUuidFromKeychain else {
            return []
        }
        let interestDBData = InterestCoreDataManager.sharedInstance.getInterestsForUser(userUuid: userUuid)
        var interests = F4SInterestSet()
        for interestDB in interestDBData {
            let interest = InterestDBOperations.sharedInstance.getInterestFromInterestDB(interestDB: interestDB)
            interests.insert(interest)
        }
        return interests
    }

    func getAllInterests() -> [F4SInterest] {
        let interestDBData = InterestCoreDataManager.sharedInstance.getAllInterests()
        var interests: [F4SInterest] = []
        for interestDB in interestDBData {
            let interest = InterestDBOperations.sharedInstance.getInterestFromInterestDB(interestDB: interestDB)
            interests.append(interest)
        }
        return interests
    }

    func removeUserInterestWithUuid(_ interestUuid: String) {
        guard let userUuid = F4SUser.userUuidFromKeychain else {
            return
        }
        InterestCoreDataManager.sharedInstance.removeInterestWithId(interestUuid: interestUuid, userUuid: userUuid)
    }

    fileprivate func getInterestFromInterestDB(interestDB: InterestDB) -> F4SInterest {
        var interest = F4SInterest(id: Int(interestDB.id))
        if let uuid = interestDB.uuid {
            interest.uuid = uuid
        }
        if let name = interestDB.name {
            interest.name = name
        }
        return interest
    }
}
