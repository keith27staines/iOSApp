//
//  Date+Extensions.swift
//  WorkfinderCommon
//
//  Created by Keith Dev on 25/03/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation

public extension Locale {
    static var workfinder: Locale {
        return Locale(identifier: "en_US_POSIX")
    }
}

public extension TimeZone {
    static var workfinder: TimeZone {
        return TimeZone(secondsFromGMT: 0)!
    }
}

public extension Calendar {
    
    static var workfinderCalendar: Calendar {
        var calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        calendar.timeZone = TimeZone.workfinder
        return calendar
    }
}

public extension Date {
    /// Returns true if the current instance is greater than the specified date, otherwise false
    func isGreaterThanDate(dateToCompare: Date) -> Bool {
        var isGreater = false
        if self.compare(dateToCompare as Date) == ComparisonResult.orderedDescending {
            isGreater = true
        }
        return isGreater
    }
    
    /// Returns true if the current instance is less than the specified date, otherwise false
    func isLessThanDate(dateToCompare: Date) -> Bool {
        var isLess = false
        if self.compare(dateToCompare as Date) == ComparisonResult.orderedAscending {
            isLess = true
        }
        return isLess
    }
    
    /// Returns true of the current instance and the specified date are equal
    func equalToDate(dateToCompare: Date) -> Bool {
        var isEqualTo = false
        if self.compare(dateToCompare as Date) == ComparisonResult.orderedSame {
            isEqualTo = true
        }
        return isEqualTo
    }
}

extension Date {
    struct DateFormatters {
        private static var _rfc3339UtcDateFormatter: DateFormatter?
        private static var _rfc3339UtcDateTimeFormatter: DateFormatter?
        private static var _rfc3339UtcDateTimeSubsecondFormatter: DateFormatter?
        
        static var rfc3339UtcDateFormatter: DateFormatter {
            if _rfc3339UtcDateFormatter == .none {
                _rfc3339UtcDateFormatter = DateFormatter()
                _rfc3339UtcDateFormatter?.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale?
                _rfc3339UtcDateFormatter?.dateFormat = "yyyy'-'MM'-'dd"
                _rfc3339UtcDateFormatter?.timeZone = NSTimeZone(forSecondsFromGMT: 0) as TimeZone?
            }
            
            return _rfc3339UtcDateFormatter!
        }
        
        static var rfc3339UtcDateTimeFormatter: DateFormatter {
            if _rfc3339UtcDateTimeFormatter == .none {
                _rfc3339UtcDateTimeFormatter = DateFormatter()
                _rfc3339UtcDateTimeFormatter?.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale?
                _rfc3339UtcDateTimeFormatter?.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ssXXXXX"
                _rfc3339UtcDateTimeFormatter?.timeZone = TimeZone.workfinder
            }
            
            return _rfc3339UtcDateTimeFormatter!
        }
        
        static var rfc3339UtcDateTimeSubsecondFormatter: DateFormatter {
            if _rfc3339UtcDateTimeSubsecondFormatter == .none {
                _rfc3339UtcDateTimeSubsecondFormatter = DateFormatter()
                _rfc3339UtcDateTimeSubsecondFormatter?.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale?
                _rfc3339UtcDateTimeSubsecondFormatter?.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSSSSXXXXX"
                _rfc3339UtcDateTimeSubsecondFormatter?.timeZone = TimeZone.workfinder
            }
            
            return _rfc3339UtcDateTimeSubsecondFormatter!
        }
    }
    
    /**
     Date part formatted for posting JSON data to the REST API.
     
     This value should not be used for formatting dates to be displayed in the user interface.
     */
    var rfc3339UtcDate: String { return DateFormatters.rfc3339UtcDateFormatter.string(from: self) }
    
    /**
     Date and time formatted for posting JSON data to the REST API.
     
     This value should not be used for formatting dates to be displayed in the user interface.
     */
    var rfc3339UtcDateTime: String { return DateFormatters.rfc3339UtcDateTimeFormatter.string(from: self) }
    
    /**
     Attempts to parse a date time expecting something like 2016-10-19T13:45:23.000Z.
     
     This function is intended for parsing dates received from the REST API.
     
     - parameter string: Input string to parse into a NSDate
     - returns: Date if the string could be successfully parsed, nil otherwise.
     */
    public static func dateFromRfc3339(string: String) -> Date? {
        if let date = DateFormatters.rfc3339UtcDateFormatter.date(from: string) {
            return date
        }
        if let date = DateFormatters.rfc3339UtcDateTimeFormatter.date(from: string) {
            return date
        }
        return DateFormatters.rfc3339UtcDateTimeSubsecondFormatter.date(from: string)
    }
    
    public func dateToStringRfc3339() -> String? {
        let dateString = DateFormatters.rfc3339UtcDateTimeFormatter.string(from: self)
        if !dateString.isEmpty {
            return dateString
        } else {
            return DateFormatters.rfc3339UtcDateTimeSubsecondFormatter.string(from: self)
        }
    }
}
