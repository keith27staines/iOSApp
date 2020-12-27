//
//  F4SAvailabilityPeriod.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 09/04/2018.
//  Copyright © 2018 Workfinder Ltd. All rights reserved.
//

import Foundation

/// Represents an interval between a first and last date during which the YP is
/// available for work experience. The interval is refined by the addition of
/// a structure that indicates day-of-the-week availability, with each day being
/// selectable and further qualified by either am (which by convention is taken
/// to mean 9am to 12), pm (12 - 5pm) or all.
/// Note that the rules for day-of-the-week availaility are lax. It is legitimate
/// to specify a day that is excluded by the first and last dates (this can
/// happen if the interval between those dates is less than a week). However,
/// the first to last date interval is taken to override the day of the week
/// specification, so that if, say, a Monday is specified as "available", yet the
/// interval between the first and last dates does not contain a Monday, then
/// the Monday availability will be ignored
public struct F4SAvailabilityPeriod {
    /// first day of availability
    public var firstDay: F4SCalendarDay?
    /// last day of availability
    public var lastDay: F4SCalendarDay?
    /// availabiity refined according to day of the week
    public var daysAndHours: F4SDaysAndHoursModel?
    
    /// returns a json struct that represents the current instance
    public func makeAvailabilityPeriodJson() -> F4SAvailabilityPeriodJson {
        let start_date = F4SAvailabilityPeriod.formatYearString(day: self.firstDay)
        let end_date = F4SAvailabilityPeriod.formatYearString(day: self.lastDay)
        let times = F4SAvailabilityPeriod.times(daysAndHours: daysAndHours)
        let period = F4SAvailabilityPeriodJson(start_date: start_date, end_date: end_date, day_time_info: times)
        return period
    }
    
    
    /// initialise a new instance
    ///
    /// Represents an interval between a first and last date during which the YP is
    /// available for work experience. The interval is refined by the addition of
    /// a structure that indicates day-of-the-week availability, with each day being
    /// selectable and further qualified by either am (which by convention is taken
    /// to mean 9am to 12), pm (12 - 5pm) or all
    ///
    /// - Notes: The rules for day-of-the-week availaility are lax. It is legitimate
    /// to specify a day that is excluded by the first and last dates (this can
    /// happen if the interval between those dates is less than a week). However,
    /// the first to last date interval is taken to override the day of the week
    /// specification, so that if, say, a Monday is specified as "available", yet the
    /// interval between the first and last dates does not contain a Monday, then
    /// the Monday availability will be ignored
    ///
    /// - Parameters:
    ///   - firstDay: first day of availability
    ///   - lastDay: last day of availability
    ///   - daysAndHours: a refinement of availability by day of the week
    public init(firstDay: F4SCalendarDay?, lastDay: F4SCalendarDay?, daysAndHours: F4SDaysAndHoursModel?) {
        self.firstDay = firstDay
        self.lastDay = lastDay
        self.daysAndHours = daysAndHours
    }
    
    /// initialise a new instance
    ///
    /// Represents an interval between a first and last date during which the YP is
    /// available for work experience. The interval is refined by the addition of
    /// a structure that indicates day-of-the-week availability, with each day being
    /// selectable and further qualified by either am (which by convention is taken
    /// to mean 9am to 12), pm (12 - 5pm) or all
    ///
    /// - Notes: The rules for day-of-the-week availaility are lax. It is legitimate
    /// to specify a day that is excluded by the first and last dates (this can
    /// happen if the interval between those dates is less than a week). However,
    /// the first to last date interval is taken to override the day of the week
    /// specification, so that if, say, a Monday is specified as "available", yet the
    /// interval between the first and last dates does not contain a Monday, then
    /// the Monday availability will be ignored
    ///
    /// - Parameters:
    ///    - availabilityPeriodJson: A struct directly representing json required
    /// by the server
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
    
    /// nullifes the first (and last, if necessary) date of the availability interval. This
    /// supports situations where the current date has advanced beyond the start of the availability interval
    /// The days and hours availability structure is left unchanged by this
    /// operation
    public func nullifyingInvalidStartOrEndDates() -> F4SAvailabilityPeriod {
        var period = self
        period.firstDay = dayIsValid(day: firstDay) ? firstDay : nil
        period.lastDay = dayIsValid(day: lastDay) ? lastDay : nil
        return period
    }
    
    /// Tests whether the specified day is valid for availability. If the day is
    /// in the past relative to "today" then it is invalid; otherwise it is
    /// valid
    func dayIsValid(day: F4SCalendarDay?) -> Bool {
        guard let day = day else { return true }
        return !day.isInPast
    }
    
    /// Returns a date from a "yyyy-MM-dd" string
    static func dateFromString(_ dateString: String?) -> Date? {
        guard let dateString = dateString else { return nil }
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.workfinder
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.date(from: dateString)
        return date
    }
    
    /// Returns a new [F4SDayTimeInfoJson] from a F4SDaysAndHoursModel
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
    
    /// Returns a "yyyy-MM-dd" string representation of an F4SCalendarDay
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
    public init(availability_periods: [F4SAvailabilityPeriodJson]) {
        self.availability_periods = availability_periods
    }
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
    public init(dayIsSelected: Bool,
                dayOfWeek: F4SDayOfWeek,
                hoursType: F4SHoursType,
                contiguousPeriods: [DateInterval]?) {
        self.dayIsSelected = dayIsSelected
        self.contiguousPeriods = contiguousPeriods
        self.dayOfWeek = dayOfWeek
        self.hoursType = hoursType
        
    }
}
