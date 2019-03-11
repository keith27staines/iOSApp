//
//  F4SCalendarMonth.swift
//  HoursPicker2
//
//  Created by Keith Dev on 20/03/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation

public struct F4SCalendarMonth {
    
    public private (set) var days: [F4SCalendarDay]
    public private (set) var cal: F4SCalendar
    public var firstDay: F4SCalendarDay { return days.first! }
    public var lastDay: F4SCalendarDay { return days.last! }
    
    public init(cal: F4SCalendar, date: Date) {
        let day = F4SCalendarDay(cal: cal, date: date)
        self.init(containing: day)
    }
    
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
    
    public var veryShortMonthSymbol: String {
        let monthSymbols = self.cal.dateFormatter.veryShortMonthSymbols!
        return monthSymbols[monthNumber - 1]
    }
    
    public var shortMonthSymbol: String {
        let monthSymbols = self.cal.dateFormatter.shortMonthSymbols!
        return monthSymbols[monthNumber - 1]
    }
    
    public var monthSymbol: String {
        let monthSymbols = self.cal.dateFormatter.monthSymbols!
        return monthSymbols[monthNumber - 1]
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
        return cal.monthNumber(date: firstDay.midday)
    }
    
    public var year: Int {
        return cal.yearNumber(date: firstDay.midday)
    }
}
