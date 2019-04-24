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
    public var daysAndHours: F4SDaysAndHoursModel?
    
    public func makeAvailabilityPeriodJson() -> F4SAvailabilityPeriodJson {
        let start_date = F4SAvailabilityPeriod.formatYearString(day: self.firstDay)
        let end_date = F4SAvailabilityPeriod.formatYearString(day: self.lastDay)
        let times = F4SAvailabilityPeriod.times(daysAndHours: daysAndHours)
        let period = F4SAvailabilityPeriodJson(start_date: start_date, end_date: end_date, day_time_info: times)
        return period
    }
    
    public init(firstDay: F4SCalendarDay?, lastDay: F4SCalendarDay?, daysAndHours: F4SDaysAndHoursModel?) {
        self.firstDay = firstDay
        self.lastDay = lastDay
        self.daysAndHours = daysAndHours
    }
    
    public init(availabilityPeriodJson: F4SAvailabilityPeriodJson?) {
        guard let availabilityPeriodJson = availabilityPeriodJson else {
            self.init(firstDay: nil, lastDay: nil, daysAndHours: nil)
            return
        }
        // Create a new day hours model with default selection settings
        let daysAndHours = F4SDaysAndHoursModel()
        
        // update model with persisted data
        for dayHourSelection in daysAndHours.allDays {
            let symbol = dayHourSelection.dayOfWeek.twoLetterSymbol
            guard let jsonDay = availabilityPeriodJson.day_time_info?.filter({ (dayTime) -> Bool in
                return dayTime.day == symbol
            }).first else {
                daysAndHours.selectDays(value: false) { (dh) -> Bool in
                    // No information for this day was persisted so deselect it and continue to next
                    dh.dayOfWeek == dayHourSelection.dayOfWeek
                }
                continue
            }
            
            let hoursType = F4SHoursType(rawValue: jsonDay.time)
            daysAndHours.setHoursForDay(hoursType: hoursType!, day: dayHourSelection)
            daysAndHours.selectDays(value: true) { (dh) -> Bool in
                dh.dayOfWeek == dayHourSelection.dayOfWeek
            }
        }
        
        let cal = F4SCalendar()
        let firstDate = F4SAvailabilityPeriod.dateFromString(availabilityPeriodJson.start_date)
        let lastDate = F4SAvailabilityPeriod.dateFromString(availabilityPeriodJson.end_date)
        let firstDay = firstDate == nil ? nil : F4SCalendarDay(cal: cal, date: firstDate!)
        let lastDay = lastDate == nil ? nil : F4SCalendarDay(cal: cal, date: lastDate!)
        self.init(firstDay: firstDay, lastDay: lastDay, daysAndHours: daysAndHours)
    }
    
    public func nullifyingInvalidStartOrEndDates() -> F4SAvailabilityPeriod {
        var period = self
        period.firstDay = dayIsValid(day: firstDay) ? firstDay : nil
        period.lastDay = dayIsValid(day: lastDay) ? lastDay : nil
        return period
    }
    
    func dayIsValid(day: F4SCalendarDay?) -> Bool {
        guard let day = day else { return true }
        return day.isInFuture
    }
    
    static func dateFromString(_ dateString: String?) -> Date? {
        guard let dateString = dateString else { return nil }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.date(from: dateString)
        return date
    }
    
    private static func times(daysAndHours: F4SDaysAndHoursModel?) -> [F4SDayTimeInfoJson] {
        var times = [F4SDayTimeInfoJson]()
        guard let daysAndHours = daysAndHours else { return times }
        for dayHour in daysAndHours.allDays {
            guard dayHour.dayIsSelected else { continue }
            guard dayHour.hoursType != .custom else { continue }
            let time = F4SDayTimeInfoJson(dayAndHours: dayHour)
            times.append(time)
        }
        return times
    }
    
    private static func formatYearString(day: F4SCalendarDay?) -> String? {
        guard let day = day else { return nil }
        let yearString = String(day.year)
        let monthString = String(day.monthOfYear)
        let dayString = String(day.dayOfMonth)
        return "\(yearString)-\(monthString)-\(dayString)"
    }
}

// JSON objects that models this structure:
//     {
//          'availability_periods': [
//             {
//                 'start_date': '2018-06-01',
//                 'end_date': '2018-08-01',
//                 'day_time_info': [
//                     {
//                         'day': 'MO',
//                         'time': 'am'
//                     },
//                     {
//                         'day': 'TU',
//                         'time': 'all'
//                     },
//                     {
//                         'day': 'WE',
//                         'time': 'pm'
//                     },
//                 ]
//             }
//         ]
//     }

public struct F4SAvailabilityPeriodsJson : Codable {
    public var availability_periods: [F4SAvailabilityPeriodJson]
}

public struct F4SAvailabilityPeriodJson : Codable {
    public var start_date: String?
    public var end_date: String?
    public var day_time_info: [F4SDayTimeInfoJson]?
    
    public init() {
        start_date = nil
        end_date = nil
        let mon = F4SDayTimeInfoJson(day: F4SDayOfWeek.monday, hourType: F4SHoursType.all)
        let tue = F4SDayTimeInfoJson(day: F4SDayOfWeek.tuesday, hourType: F4SHoursType.all)
        let wed = F4SDayTimeInfoJson(day: F4SDayOfWeek.wednesday, hourType: F4SHoursType.all)
        let thu = F4SDayTimeInfoJson(day: F4SDayOfWeek.thursday, hourType: F4SHoursType.all)
        let fri = F4SDayTimeInfoJson(day: F4SDayOfWeek.friday, hourType: F4SHoursType.all)
        day_time_info = [F4SDayTimeInfoJson]()
        day_time_info?.append(mon)
        day_time_info?.append(tue)
        day_time_info?.append(wed)
        day_time_info?.append(thu)
        day_time_info?.append(fri)
    }
    
    public init(start_date: String? = nil, end_date: String? = nil, day_time_info: [F4SDayTimeInfoJson]? = nil) {
        self.start_date = start_date
        self.end_date = end_date
        self.day_time_info = day_time_info
    }
}

/// Represents the day and time info
public struct F4SDayTimeInfoJson : Codable {
    /// MO | TU | WE | TH | FR | SA | SU
    public var day: String
    /// am | pm | all
    public var time: String
    
    public init(day: String, time: String) {
        self.day = day
        self.time = time
    }
    
    public init(dayAndHours: F4SDayAndHourSelection){
        self.day = dayAndHours.dayOfWeek.twoLetterSymbol
        self.time = dayAndHours.hoursType.rawValue
    }
    
    public init(day: F4SDayOfWeek, hourType: F4SHoursType) {
        self.day = day.twoLetterSymbol
        self.time = hourType.rawValue
    }
}

public struct F4SDayAndHourSelection {
    public var dayIsSelected: Bool
    public var dayOfWeek: F4SDayOfWeek
    public var hoursType: F4SHoursType
    public var contiguousPeriods: [DateInterval]?
}

public struct F4SCalendarDay : Equatable, Comparable {
    
    public static func <(lhs: F4SCalendarDay, rhs: F4SCalendarDay) -> Bool {
        return lhs.midday < rhs.midday
    }
    
    public static func ==(lhs: F4SCalendarDay, rhs: F4SCalendarDay) -> Bool {
        return lhs.midday == rhs.midday
    }
    
    public let midday: Date // midday
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
