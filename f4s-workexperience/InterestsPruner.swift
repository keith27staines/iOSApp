//
//  F4SInterestsRepository.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 07/04/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation
import WorkfinderCommon

public class F4SInterestsRepository : F4SInterestsRepositoryProtocol {
    
    public func loadAllInterests() -> [F4SInterest] {
        return InterestDBOperations.sharedInstance.getAllInterests()
    }
    
    public func loadUserInterests() -> [F4SInterest] {
        let allInterests = loadAllInterests()
        let validInterestsSet = pruneInvalidUserInterests(validInterests: allInterests)
        return [F4SInterest](validInterestsSet)
    }
    
    /// Prunes interests that no longer appear in the live database from the user's interest list
    /// - Returns: set of good interests
    func pruneInvalidUserInterests(validInterests: [F4SInterest]) -> F4SInterestSet {
        let userInterestSet = InterestDBOperations.sharedInstance.interestsForCurrentUser()
        let allInterestsSet = Set(validInterests)
        let intersection = userInterestSet.intersection(allInterestsSet)
        let badInterests = userInterestSet.subtracting(intersection)
        badInterests.forEach { InterestDBOperations.sharedInstance.removeUserInterestWithUuid($0.uuid) }
        return intersection
    }
}



