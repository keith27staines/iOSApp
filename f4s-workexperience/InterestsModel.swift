//
//  InterestsModel.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 12/10/2017.
//  Copyright © 2017 Founders4Schools. All rights reserved.
//

import Foundation

/// A dictionary mapping interests to the number of companies having that interest
public typealias F4SInterestCounts = [Interest:Int]

public struct InterestsModel {
    
    /// A dictionary of all interests, keyed by their id
    public let allInterests: [Int64: Interest]
    
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
    /// - parameter interests: The set of interests companies are to be tested against
    /// - parameter companyPins: The set of company pins to be examined
    /// - returns: A tuple containing...
    ///     - the total number of companies having one or more of the interests
    ///     - a dictionary containing the number of companies having each interest
    func interestCounts(interests:F4SInterestSet, companyPins: F4SCompanyPinSet) -> (Int,[Interest:Int]) {
        var interestCounts = [Interest:Int]()
        var total: Int = 0
        for pin in companyPins {
            let pinInterests = interestSetFromIdSet(pin.interestIds)
            guard !pinInterests.intersection(interests).isEmpty else {
                continue
            }
            total += 1
            for interest in pinInterests {
                let count = interestCounts[interest] ?? 0
                interestCounts[interest] = count + 1
            }
        }
        return (total: total, interestCounts: interestCounts)
    }
}
