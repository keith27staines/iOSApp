//
//  F4SCalendarDay.swift
//  HoursPicker2
//
//  Created by Keith Dev on 20/03/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation

/// Models a calendar day
public struct F4SCalendarDay : Equatable, Comparable {
    
    public static func <(lhs: F4SCalendarDay, rhs: F4SCalendarDay) -> Bool {
        return lhs.midday < rhs.midday
    }
    
    public static func ==(lhs: F4SCalendarDay, rhs: F4SCalendarDay) -> Bool {
        return lhs.midday == rhs.midday
    }
    
    let midday: Date // midday
    let cal: F4SCalendar
    
    /// Creates a new instance with a calendar and a date it is to contain
    public init(cal: F4SCalendar, date: Date) {
        self.cal = cal
        self.midday = cal.middayOfDayContaining(date: date)
    }
    
    /// Returns the F4SDay this day represents
    public var dayOfWeek: F4SDayOfWeek {
        return cal.dayOfWeekContaining(date: midday)
    }
    
    /// Returns a DateInterval spanning the day
    public var interval: DateInterval {
        return cal.intervalForDayContaining(date: midday)
    }
    
    /// Returns a new day that follows the current day
    public var nextDay: F4SCalendarDay {
        let nextMidday = midday.addingTimeInterval(24*3600)
        return F4SCalendarDay(cal: cal, date: nextMidday)
    }
    
    /// Returns a new day that preceeds the current day
    public var previousDay: F4SCalendarDay {
        let previousMidday = midday.addingTimeInterval(-24*3600)
        return F4SCalendarDay(cal: cal, date: previousMidday)
    }
    
    public func addingDays(_ number: Int) -> F4SCalendarDay {
        var day = self
        var daysLeftToAdd = abs(number)
        while daysLeftToAdd != 0 {
            daysLeftToAdd -= 1
            day = day.nextDay
        }
        return day
    }
    
    public func subtractingDays(_ number: Int) -> F4SCalendarDay {
        var day = self
        var daysLeftToSubtract = abs(number)
        while daysLeftToSubtract != 0 {
            daysLeftToSubtract -= 1
            day = day.previousDay
        }
        return day
    }
    
    /// Returns the year number that contains the current instance
    public var year: Int {
        return cal.yearNumber(date: midday)
    }
    
    /// returns the month number that contains the current instance
    public var monthOfYear: Int {
        return cal.monthNumber(date: midday)
    }
    
    /// Returns the day of the month for the current instance
    public var dayOfMonth: Int {
        return cal.dayNumber(date: midday)
    }
    
    public var isToday: Bool {
        let today = F4SCalendarDay(cal: cal, date: Date())
        return self == today
    }
    
    public var isSixWeeksIntoFuture: Bool {
        let today = F4SCalendarDay(cal: cal, date: Date())
        let cutoff = today.addingDays(6 * 7)
        return self >= cutoff
    }
    
    public var isInPast: Bool {
        let today = F4SCalendarDay(cal: cal, date: Date())
        return self < today
    }
    
    public var isInFuture: Bool {
        let today = F4SCalendarDay(cal: cal, date: Date())
        return self > today
    }
}
