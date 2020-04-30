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
    
    /// A dictionary of all interests, keyed by their uuid
    public let allInterests: F4SInterestSet
    
    public init(allInterests: F4SInterestSet) {
        self.allInterests = allInterests
    }
    
    /// returns a set of interests corresponding to the set of interest ids
    public func validInterestsFrom(uncheckedInterests: F4SInterestSet) -> F4SInterestSet {
        var interestSet = F4SInterestSet()
        for uncheckedInterest in uncheckedInterests {
            guard allInterests.contains(uncheckedInterest) else { continue }
            interestSet.insert(uncheckedInterest)
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
        for companyPin in companyPins {
            let pinInterests = companyPin.interests
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
