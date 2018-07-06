//
//  F4SMonthDisplay.swift
//  HoursPicker2
//
//  Created by Keith Dev on 20/03/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation


public struct F4SDisplayableMonth {
    
    public var month: F4SCalendarMonth
    public private (set) var leadingDays: [F4SCalendarDay]? =  nil
    public private (set) var trailingDays: [F4SCalendarDay]? = nil
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
    
    public init(cal: F4SCalendar, date: Date) {
        let day = F4SCalendarDay(cal: cal, date: date)
        self.init(containing: day)
    }
    
    public init(containing day: F4SCalendarDay) {
        cal = day.cal
        month = F4SCalendarMonth(containing: day)
        leadingDays = findLeadingDays()
        trailingDays = findTrailingDays()
    }
    
    private func findLeadingDays() -> [F4SCalendarDay]? {
        var leadingDays = [F4SCalendarDay]()
        var leadingDay: F4SCalendarDay = month.firstDay
        while leadingDay.dayOfWeek != F4SDayOfWeek.monday {
            leadingDay = leadingDay.previousDay
            leadingDays.append(leadingDay)
        }
        return leadingDays.isEmpty ? nil : leadingDays.sorted()
    }
    
    private func findTrailingDays() -> [F4SCalendarDay]? {
        var trailingDays = [F4SCalendarDay]()
        var trailingDay: F4SCalendarDay = month.lastDay
        while trailingDay.dayOfWeek != F4SDayOfWeek.sunday {
            trailingDay = trailingDay.nextDay
            trailingDays.append(trailingDay)
        }
        return trailingDays.isEmpty ? nil : trailingDays.sorted()
    }
    
    public var interval: DateInterval {
        return DateInterval(start: firstDay.interval.start, end: lastDay.interval.end)
    }
    
    public var next: F4SCalendarMonth {
        let firstDayNextMonth = lastDay.nextDay
        return F4SCalendarMonth(containing: firstDayNextMonth)
    }
    
    public var previous: F4SCalendarMonth {
        let lastDayPreviousMonth = firstDay.previousDay
        return F4SCalendarMonth(containing: lastDayPreviousMonth)
    }
    
    public var monthNumber: Int {
        return month.monthNumber
    }
    
    public func monthContains(day: F4SCalendarDay) -> Bool {
        return month.contains(day:day)
    }

    public func numberOfDaysToDisplay() -> Int {
        var n = leadingDays?.count ?? 0
        n += month.days.count
        n += trailingDays?.count ?? 0
        return n
    }
    
    public func dayForRow(row: Int) -> F4SCalendarDay? {
        var allDays = leadingDays ?? [F4SCalendarDay]()
        allDays += month.days
        allDays += trailingDays ?? [F4SCalendarDay]()
        return allDays[row]
    }
    
    public func leadingDaysContains(day: F4SCalendarDay) -> Bool {
        guard let leading = leadingDays else { return false }
        return leading.first! <= day && day <= leading.last!
    }
    
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











