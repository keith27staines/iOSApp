//
//  WorkAvailabilityWindow.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 24/10/2017.
//  Copyright © 2017 Founders4Schools. All rights reserved.
//

import Foundation

/// States
public enum WorkAvailabilityWindowStatus {
    case valid
    case invalidStartDateMissing
    case invalidEndDateMissing
    case invalidStartsTooEarly
    case invalidEndsTooEarly
}

/// Models a wndow of availability
public struct WorkAvailabilityWindow {
    /// The submission date of the application
    public let submission: Date
    /// The start of the applicant's availability window
    public let start: Date?
    /// The end of the applicant's availability window
    public let end: Date?
    
    var status: WorkAvailabilityWindowStatus {
        guard let start = self.start else {
            return WorkAvailabilityWindowStatus.invalidStartDateMissing
        }
        guard let end = self.end else {
            return WorkAvailabilityWindowStatus.invalidEndDateMissing
        }
        if start < WorkAvailabilityWindow.earliestStartDate(submission: self.submission) {
            return WorkAvailabilityWindowStatus.invalidStartsTooEarly
        }
        if end < WorkAvailabilityWindow.earliestEndDate(start: start, submission: self.submission) {
            return WorkAvailabilityWindowStatus.invalidEndsTooEarly
        }
        return WorkAvailabilityWindowStatus.valid
    }
    
    /// Returns the earliest valid start date. In the current implementation this is the start of the day of submission
    ///
    /// - parameter submission: The date of submission
    public static func earliestStartDate(submission:Date) -> Date {
        var components = DateComponents()
        components.day = 0
        let nextDay = Calendar.current.date(byAdding: components, to: submission)!
        return nextDay.startOfDay
    }
    
    /// Returns true if start is valid relative to the submission date
    ///
    /// - parameter start: The potential availability start date to be tested
    /// - parameter submission: The submission date
    public static func isStartDateValid(_ start: Date, submission: Date) -> Bool {
        let earliestStart = earliestStartDate(submission: submission)
        return earliestStart.isLessThanDate(dateToCompare: start)
    }
    
    /// Returns true if end date is valid relative to the submission date and start date
    ///
    /// - parameter end: The potential availability end date to be tested
    /// - parameter start: The availability start date
    /// - parameter submission: The submission date
    public static func isEndDateValid(end: Date, start: Date, submission: Date) -> Bool {
        let earliestEnd = earliestEndDate(start: start, submission: submission)
        return earliestEnd.isLessThanDate(dateToCompare: end)
    }

    
    /// Returns the earliest valid end date. In the current implementation, this is the end of either the submission day or the start day, whichever is later
    ///
    /// - parameter start: The availability start date
    /// - submission: The date of the submission
    public static func earliestEndDate(start: Date, submission: Date) -> Date {
        let mustBeAfter = submission > start ? submission : start
        return mustBeAfter.endOfDay
    }
    
    /// Initialises a new instance from specified start and end days and a submission date
    ///
    /// - parameter startDay: A date and time contained within the day of the start of availability
    /// - parameter end: A date and time contained within the day of the end of availability
    /// - parameter submission: The date and time of the submission
    public init(startDay: Date?, endDay: Date?, submission: Date) {
        self.start = startDay?.startOfDay
        self.end = endDay?.endOfDay
        self.submission = submission
    }
}

public extension Date {
    /// Returns a date corresponding to the first instant of the current instance
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    /// Returns a date corresponding to a second before the end of the day that contains the current instance
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }
}

