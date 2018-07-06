//
//  F4SCalendarWeek.swift
//  HoursPicker2
//
//  Created by Keith Dev on 20/03/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation

/// Models a calendar week
public struct F4SCalendarWeek {
    
    /// An array of days that make up the week
    public private (set) var days: [F4SCalendarDay]
    
    /// The underlying calendar that ultimately performs date arithmetic
    public private (set) var cal: F4SCalendar
    
    /// Returns the first day of the week
    public var firstDay: F4SCalendarDay { return days.first! }
    
    /// Returns the last day of the week
    public var lastDay: F4SCalendarDay { return days.last! }
    
    /// Creates a new instance
    public init(cal: F4SCalendar, date: Date) {
        let day = F4SCalendarDay(cal: cal, date: date)
        self.init(containing: day)
    }
    
    /// Creates a new instance
    public init(containing day: F4SCalendarDay) {
        cal = day.cal
        days = [F4SCalendarDay]()
        var d = day
        while d.dayOfWeek != F4SDayOfWeek.monday {
            d = d.previousDay
        }
        days.append(d)
        while d.dayOfWeek != F4SDayOfWeek.sunday {
            d = d.nextDay
            days.append(d)
        }
    }
    
    /// Returns true if the current week contains the specified day
    public func contains(day: F4SCalendarDay) -> Bool {
        return firstDay <= day && day <= lastDay
    }
    
    /// Returns the DateInterval that spans the current instance
    public var interval: DateInterval {
        return DateInterval(start: firstDay.interval.start, end: lastDay.interval.end )
    }
    
    /// Returns a new instance representing the following week
    public var next: F4SCalendarWeek {
        let firstDayNextWeek = lastDay.nextDay
        return F4SCalendarWeek(cal: cal, date: firstDayNextWeek.midday)
    }
    
    /// Returns a new instance representing the preceeding week
    public var previous: F4SCalendarWeek {
        let lastDayLastWeek = firstDay.previousDay
        return F4SCalendarWeek(cal: cal, date: lastDayLastWeek.midday)
    }
}
