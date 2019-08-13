//
//  F4SCalendarMonth.swift
//  HoursPicker2
//
//  Created by Keith Dev on 20/03/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation

/// Models a calendar month
public struct F4SCalendarMonth {
    
    /// An array of days that make up the month
    public private (set) var days: [F4SCalendarDay]

    public private (set) var cal: F4SCalendar
    
    /// The first day of the month
    public var firstDay: F4SCalendarDay { return days.first! }
    /// The last day of the month
    public var lastDay: F4SCalendarDay { return days.last! }
    
    
    /// Initialises a new month that includes the specified date
    ///
    /// - Parameters:
    ///   - cal: a calendar instance
    ///   - date: any date within the required month
    public init(cal: F4SCalendar, date: Date) {
        let day = F4SCalendarDay(cal: cal, date: date)
        self.init(containing: day)
    }
    
    /// Initialises a new month that includes the specified day
    ///
    /// - Parameters:
    ///   - cal: a calendar instance
    ///   - day: any day within the required month
    public init(containing day: F4SCalendarDay) {
        cal = day.cal
        days = [F4SCalendarDay]()
        var d: F4SCalendarDay = day
        while d.dayOfMonth > 1 {
            d = d.previousDay
        }
        let numberOfDaysInMonth = cal.numberOfDaysInMonthContaining(date: day.midday)
        days.append(d)
        while d.dayOfMonth < numberOfDaysInMonth {
            d = d.nextDay
            days.append(d)
        }
    }
    
    /// Returns true if the current month contains the specified day
    public func contains(day: F4SCalendarDay) -> Bool {
        return firstDay <= day && day <= lastDay
    }
    
    /// Returns the very short symbol of the month
    public var veryShortMonthSymbol: String {
        let monthSymbols = self.cal.dateFormatter.veryShortMonthSymbols!
        return monthSymbols[monthNumber - 1]
    }
    
    /// Returns the short symbol of the month
    public var shortMonthSymbol: String {
        let monthSymbols = self.cal.dateFormatter.shortMonthSymbols!
        return monthSymbols[monthNumber - 1]
    }
    
    /// Returns the full symbol of the month
    public var monthSymbol: String {
        let monthSymbols = self.cal.dateFormatter.monthSymbols!
        return monthSymbols[monthNumber - 1]
    }
    
    /// Returns the interval spanning the month
    public var interval: DateInterval {
        return DateInterval(start: firstDay.interval.start, end: lastDay.interval.end)
    }
    
    /// Returns the month after the current instance (may be in
    /// the next year)
    public var next: F4SCalendarMonth {
        let firstDayNextMonth = lastDay.nextDay
        return F4SCalendarMonth(containing: firstDayNextMonth)
    }
    
    /// Returns the month before the current instance (may be in
    /// the previous month)
    public var previous: F4SCalendarMonth {
        let lastDayPreviousMonth = firstDay.previousDay
        return F4SCalendarMonth(containing: lastDayPreviousMonth)
    }
    
    /// Returns the month number (1 - 12)
    public var monthNumber: Int {
        return cal.monthNumber(date: firstDay.midday)
    }
    
    /// Returns the year containing the month
    public var year: Int {
        return cal.yearNumber(date: firstDay.midday)
    }
}
