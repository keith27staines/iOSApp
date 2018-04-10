//
//  F4SAvailabilityPeriod.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 09/04/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation


public struct F4SAvailabilityPeriod {
    
    public var firstDay: F4SCalendarDay?
    public var lastDay: F4SCalendarDay?
    public var daysAndHours: F4SDaysAndHoursModel
    
    public var availabilityJson: F4SAvailabilityPeriodsJson? {
        guard let firstDay = self.firstDay, let lastDay = self.lastDay else { return nil }
        let start_date = F4SAvailabilityPeriod.formatYearString(day: firstDay)
        let end_date = F4SAvailabilityPeriod.formatYearString(day: lastDay)
        let times = F4SAvailabilityPeriod.times(daysAndHours: daysAndHours)
        let period = F4SAvailabilityPeriodJson(start_date: start_date, end_date: end_date, day_time_info: times)
        let jsonObject = F4SAvailabilityPeriodsJson(availability_periods: [period])
        return jsonObject
    }
    
    public init(firstDay: F4SCalendarDay?, lastDay: F4SCalendarDay?, daysAndHours: F4SDaysAndHoursModel?) {
        self.firstDay = firstDay
        self.lastDay = lastDay
        self.daysAndHours = daysAndHours ?? F4SDaysAndHoursModel()
    }
    
    private static func times(daysAndHours: F4SDaysAndHoursModel) -> [F4SDayTimeInfoJson] {
        var times = [F4SDayTimeInfoJson]()
        for day in daysAndHours.allDays {
            guard day.dayIsSelected else { continue }
            guard day.hoursType != .custom else { continue }
            let time = ["day" : day.dayOfWeek.twoLetterSymbol, "time" : day.hoursType.description]
            times.append(time)
        }
        return times
    }
    
    private static func formatYearString(day: F4SCalendarDay) -> String {
        let yearString = String(day.year)
        let monthString = String(day.monthOfYear)
        let dayString = String(day.dayOfMonth)
        return "\(yearString)-\(monthString)-\(dayString)"
    }
}
