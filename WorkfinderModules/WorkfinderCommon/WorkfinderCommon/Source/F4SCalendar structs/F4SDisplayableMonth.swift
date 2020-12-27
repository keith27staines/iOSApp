//
//  F4SMonthDisplay.swift
//  HoursPicker2
//
//  Created by Keith Dev on 20/03/2018.
//  Copyright © 2018 Workfinder Ltd. All rights reserved.
//

import Foundation

// Feb 2016 (leap year example month)
// Mon  Tue  Wed  Thu  Fri  Sat  Sun
//  01   02   03   04   05   06   07
//  08   09   10   11   12   13   14
//  15   16   17   18   19   20   21
//  22   23   24   25   26   27   28
//  29   01   02   03   04   05   06

// Feb 2017 (Non leap year example month)
// Mon  Tue  Wed  Thu  Fri  Sat  Sun
//  30   31   01   02   03   04   05
//  06   07   08   09   10   11   12
//  13   14   15   16   17   18   19
//  20   21   22   23   24   25   26
//  27   28   01   02   03   04   05


/// Models a displayable month suitable for use on a calander as depicted in above.
/// A displayable month has an array of leading days from the previous month, an
/// array of days from the month it represents, and trailing array of days from
/// the following month
public struct F4SDisplayableMonth {
    
    /// The month nominally represented by the displayable month
    public var month: F4SCalendarMonth
    /// The days from the previous month that are also displayed
    public private (set) var leadingDays: [F4SCalendarDay]? =  nil
    /// the days from the next month that are also displayed
    public private (set) var trailingDays: [F4SCalendarDay]? = nil
    
    /// A calendar used to help with dates
    public private (set) var cal: F4SCalendar
    
    /// Returns the first day of the display period
    public var firstDay: F4SCalendarDay {
        if let firstLeadingDay = leadingDays?.first {
            return firstLeadingDay
        }
        return month.firstDay
    }
    
    /// Returns the last day of the display period
    public var lastDay: F4SCalendarDay {
        if let lastTrailingDay = trailingDays?.last {
            return lastTrailingDay
        }
        return month.lastDay
    }
    
    /// Initialises a new instance
    ///
    /// - parameter cal: Used to help with date arithmetic
    /// - parameter date: Any date from the main body of the month to be displayed
    public init(cal: F4SCalendar, date: Date) {
        let day = F4SCalendarDay(cal: cal, date: date)
        self.init(containing: day)
    }
    
    /// Initialises a new instance
    ///
    /// - parameter day: Any day from the main body of the month
    public init(containing day: F4SCalendarDay) {
        cal = day.cal
        month = F4SCalendarMonth(containing: day)
        leadingDays = findLeadingDays()
        trailingDays = findTrailingDays()
    }
    
    /// Returns an array of leading days that appear before the main body of the
    /// month if any exist, otherwise nil
    private func findLeadingDays() -> [F4SCalendarDay]? {
        var leadingDays = [F4SCalendarDay]()
        var leadingDay: F4SCalendarDay = month.firstDay
        while leadingDay.dayOfWeek != F4SDayOfWeek.monday {
            leadingDay = leadingDay.previousDay
            leadingDays.append(leadingDay)
        }
        return leadingDays.isEmpty ? nil : leadingDays.sorted()
    }
    
    /// Returns an array of trailing days that appear after the main body of the
    /// month if any exist, otherwise nil
    private func findTrailingDays() -> [F4SCalendarDay]? {
        var trailingDays = [F4SCalendarDay]()
        var trailingDay: F4SCalendarDay = month.lastDay
        while trailingDay.dayOfWeek != F4SDayOfWeek.sunday {
            trailingDay = trailingDay.nextDay
            trailingDays.append(trailingDay)
        }
        return trailingDays.isEmpty ? nil : trailingDays.sorted()
    }
    
//    public var interval: DateInterval {
//        return DateInterval(start: firstDay.interval.start, end: lastDay.interval.end)
//    }
    
//    public var next: F4SCalendarMonth {
//        let firstDayNextMonth = lastDay.nextDay
//        return F4SCalendarMonth(containing: firstDayNextMonth)
//    }
    
//    public var previous: F4SCalendarMonth {
//        let lastDayPreviousMonth = firstDay.previousDay
//        return F4SCalendarMonth(containing: lastDayPreviousMonth)
//    }
    
    /// Returns the month number of the month in the main body
    public var monthNumber: Int {
        return month.monthNumber
    }
    
    /// Returns true if the main body of the month contains the specified day
    public func monthContains(day: F4SCalendarDay) -> Bool {
        return month.contains(day:day)
    }

    /// Returns a number of days that will be displayed (should always be 35)
    public func numberOfDaysToDisplay() -> Int {
        var n = leadingDays?.count ?? 0
        n += month.days.count
        n += trailingDays?.count ?? 0
        return n
    }
    
    /// Taking leading, main body and trailing days to be a single array, returns
    /// the element at index `row`
    public func dayForRow(row: Int) -> F4SCalendarDay? {
        var allDays = leadingDays ?? [F4SCalendarDay]()
        allDays += month.days
        allDays += trailingDays ?? [F4SCalendarDay]()
        return allDays[row]
    }
    
    /// Returns true if the array of leading days contains the specified day
    public func leadingDaysContains(day: F4SCalendarDay) -> Bool {
        guard let leading = leadingDays else { return false }
        return leading.first! <= day && day <= leading.last!
    }
    
    /// Returns true if the arry of trailing days containst the specified day
    public func trailingDaysContains(day: F4SCalendarDay) -> Bool {
        guard let trailing = trailingDays else { return false }
        return trailing.first! <= day && day <= trailing.last!
    }
    
    public func nextDisplayMonth() -> F4SDisplayableMonth {
        let firstDay = self.month.lastDay.nextDay
        return F4SDisplayableMonth(containing: firstDay)
    }
    
    public func previousDisplayMonth() -> F4SDisplayableMonth {
        let lastDay = self.month.firstDay.previousDay
        return F4SDisplayableMonth(containing: lastDay)
    }

}











