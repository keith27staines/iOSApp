//
//  F4SAvailabilitySequence.swift
//  HoursPicker2
//
//  Created by Keith Dev on 20/03/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation

public struct F4SAvailabilitySequence {
    
    public let dateIntervals: [DateInterval];
    
    public func availabilitySequenceByAddingInterval(interval: DateInterval) -> F4SAvailabilitySequence {
        let allIntervals = dateIntervals + [interval]
        var restructuredIntervals = F4SAvailabilitySequence.combiningOverlaps(intervals: allIntervals)
        restructuredIntervals = F4SAvailabilitySequence.combiningOverlaps(intervals: restructuredIntervals)
        return F4SAvailabilitySequence(dateIntervals: restructuredIntervals)
    }
    
    static func combiningOverlaps(intervals: [DateInterval]) -> [DateInterval] {
        var combinedIntervals = [DateInterval]()
        for (outerIndex, outerInterval) in intervals.enumerated() {
            var combinedInterval = outerInterval
            for (innerIndex, innerInterval) in intervals.enumerated() {
                if outerIndex == innerIndex {  continue }
                if outerInterval.intersects(innerInterval) {
                    combinedInterval = combinedInterval.combining(other: innerInterval)
                }
            }
            combinedIntervals.append(combinedInterval)
        }
        let sorted = combinedIntervals.sorted { (interval1, interval2) -> Bool in
            return (interval1.start < interval2.start)
        }
        return sorted
    }
}

extension DateInterval {
    func combining(other: DateInterval) -> DateInterval {
        let start = self.start <= other.start ? self.start : other.start
        let end = self.end >= other.end ? self.end : other.end
        return DateInterval(start: start, end: end)
    }
}
