//
//  InterestsModel.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 12/10/2017.
//  Copyright © 2017 Founders4Schools. All rights reserved.
//

import Foundation
import WorkfinderCommon

/// A dictionary mapping interests to the number of companies having that interest
public typealias F4SInterestCounts = [F4SInterest:Int]

public struct InterestsModel {
    
    static func interestIdSet(from interestSet: F4SInterestSet) -> F4SInterestIdSet {
        var interestIds = F4SInterestIdSet()
        for interest in interestSet {
            interestIds.insert(Int64(interest.id))
        }
        return interestIds
    }
    
    /// A dictionary of all interests, keyed by their id
    public let allInterests: [Int64: F4SInterest]
    
    /// returns a set of interests corresponding to the set of interest ids
    public func interestSetFromIdSet(_ ids: Set<Int64>) -> F4SInterestSet {
        var interestSet = F4SInterestSet()
        for id in ids {
            guard let interest = allInterests[id] else { continue }
            interestSet.insert(interest)
        }
        return interestSet
    }
    
    /// Returns a tuple containing the total count of companies having at least one interest known to the current instance, and a dictionary keyed by interests containing the number of companies having that interest
    ///
    /// - parameter displayedInterests: The set of interests companies are to be tested against
    /// - parameter selectedInterests: The subset of displayed interests that the user has actively selected
    /// - parameter companyPins: The set of company pins to be examined
    /// - returns: A tuple containing...
    ///     - the total number of companies the user might be interested in
    ///     - a dictionary keyed by interest containing values representing the number of companies having that interest
    func interestCounts(displayedInterests:F4SInterestSet,
                        selectedInterests: F4SInterestSet,
                        companyPins: F4SCompanyPinSet) -> (Int,[F4SInterest:Int]) {
        var interestCounts = [F4SInterest:Int]()
        var totalPossibilities: Int = 0
        for pin in companyPins {
            let pinInterests = interestSetFromIdSet(pin.interestIds)
            if selectedInterests.isEmpty || !selectedInterests.intersection(pinInterests).isEmpty {
                // If the user hasn't selected any interests then all companies count as possibilities.
                // If the user has selected at least one interest then a company only counts as a possibility if it shares one of those interests
                totalPossibilities += 1
            }
            guard !pinInterests.intersection(displayedInterests).isEmpty else {
                // The company has no interests and therefore doesn't add to the count for any of them
                continue
            }
            for interest in pinInterests {
                // the company has this interest so increment the count for this interest
                let count = interestCounts[interest] ?? 0
                interestCounts[interest] = count + 1
            }
        }
        return (total: totalPossibilities, interestCounts: interestCounts)
    }
}
