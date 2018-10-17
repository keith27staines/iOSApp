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
    
    public var availabilityJson: F4SAvailabilityPeriodsJson? {
        let start_date = F4SAvailabilityPeriod.formatYearString(day: self.firstDay)
        let end_date = F4SAvailabilityPeriod.formatYearString(day: self.lastDay)
        let times = F4SAvailabilityPeriod.times(daysAndHours: daysAndHours)
        let period = F4SAvailabilityPeriodJson(start_date: start_date, end_date: end_date, day_time_info: times)
        let jsonObject = F4SAvailabilityPeriodsJson(availability_periods: [period])
        return jsonObject
    }
    
    public func data() -> Data {
        return try! JSONEncoder().encode(availabilityJson)
    }
    
    public func saveToUserDefaults() {
        let userDefaults = UserDefaults.standard
        userDefaults.set(data(), forKey: "availability")
    }
    
    public static func fromUserDefaults() -> F4SAvailabilityPeriod? {
        let userDefaults = UserDefaults.standard
        guard let data = userDefaults.value(forKey: "availability") as? Data else {
            return F4SAvailabilityPeriod(firstDay: nil, lastDay: nil, daysAndHours: nil)
        }
        
        let availabilityJson = try! JSONDecoder().decode(F4SAvailabilityPeriodsJson.self, from: data)
        guard let firstPeriod = availabilityJson.availability_periods.first else {
            return F4SAvailabilityPeriod(firstDay: nil, lastDay: nil, daysAndHours: nil)
        }
        // Create a new day hours model with default selection settings
        let daysHoursModel = F4SDaysAndHoursModel()
        
        // update model with persisted data
        for dayHourSelection in daysHoursModel.allDays {
            let symbol = dayHourSelection.dayOfWeek.twoLetterSymbol
            guard let jsonDay = firstPeriod.day_time_info?.filter({ (dayTime) -> Bool in
                return dayTime.day == symbol
            }).first else {
                daysHoursModel.selectDays(value: false) { (dh) -> Bool in
                    // No information for this day was persisted so deselect it and continue to next
                    dh.dayOfWeek == dayHourSelection.dayOfWeek
                }
                continue
            }

            let hoursType = F4SHoursType(rawValue: jsonDay.time)
            daysHoursModel.setHoursForDay(hoursType: hoursType!, day: dayHourSelection)
            daysHoursModel.selectDays(value: true) { (dh) -> Bool in
                dh.dayOfWeek == dayHourSelection.dayOfWeek
            }
        }
        
        let cal = F4SCalendar()
        let firstDay: F4SCalendarDay?
        let lastDay: F4SCalendarDay?
        let firstDate = dateFromString(firstPeriod.start_date)
        let lastDate = dateFromString(firstPeriod.end_date)
        firstDay = firstDate == nil ? nil : F4SCalendarDay(cal: cal, date: firstDate!)
        lastDay = lastDate == nil ? nil : F4SCalendarDay(cal: cal, date: lastDate!)
        return F4SAvailabilityPeriod(firstDay: firstDay, lastDay: lastDay, daysAndHours: daysHoursModel)
    }
    
    static func dateFromString(_ dateString: String?) -> Date? {
        guard let dateString = dateString else { return nil }
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("yyyy-MM-dd")
        let date = dateFormatter.date(from: dateString)
        return date
    }
    
    public init(firstDay: F4SCalendarDay?, lastDay: F4SCalendarDay?, daysAndHours: F4SDaysAndHoursModel?) {
        self.firstDay = firstDay
        self.lastDay = lastDay
        self.daysAndHours = daysAndHours //?? F4SDaysAndHoursModel()
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
