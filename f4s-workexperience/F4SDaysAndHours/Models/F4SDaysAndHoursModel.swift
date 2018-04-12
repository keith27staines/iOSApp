//
//  F4SDaysAndHoursModel.swift
//  HoursPicker2
//
//  Created by Keith Dev on 28/03/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation


public class F4SDaysAndHoursModel {
    public private (set) var allDays = [F4SDayAndHourSelection]()
    
    public init() {
        allDays = [F4SDayAndHourSelection]()
        loadData()
    }
    
    private func loadData() {
        allDays = [F4SDayAndHourSelection]()
        for dayOfWeek in F4SDayOfWeek.allDaysZeroBased() {
            let day = F4SDayAndHourSelection(dayIsSelected: false, dayOfWeek: dayOfWeek, hoursType: .all, contiguousPeriods: nil)
            allDays.append(day)
        }
        selectDays(value: true, include: { (day) -> Bool in
            return !day.dayOfWeek.isWeekend
        })
        selectDays(value: false, include: { (day) -> Bool in
            return day.dayOfWeek.isWeekend
        })
    }
    
    public func setHoursForDay(hoursType: F4SHoursType, day: F4SDayAndHourSelection) {
        for (index,otherDay) in allDays.enumerated() {
            if day.dayOfWeek == otherDay.dayOfWeek {
                var updatedDay = otherDay
                updatedDay.hoursType = hoursType
                allDays[index] = updatedDay
                break
            }
        }
    }
    
    public func selectDays(value: Bool, include: (F4SDayAndHourSelection) -> Bool ) {
        var newDays = [F4SDayAndHourSelection]()
        for day in allDays {
            if include(day) {
                let newDay = F4SDayAndHourSelection(dayIsSelected: value, dayOfWeek: day.dayOfWeek, hoursType: day.hoursType, contiguousPeriods: day.contiguousPeriods)
                newDays.append(newDay)
            } else {
                newDays.append(day)
            }
        }
        allDays = newDays
    }
}
