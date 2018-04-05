//
//  F4SCalendarEnumerations.swift
//  HoursPicker2
//
//  Created by Keith Dev on 20/03/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation

public enum F4SHoursType {
    case am
    case pm
    case allDay
    case custom
    public var description : String {
        switch self {

        case .am:
            return "AM"
        case .pm:
            return "PM"
        case .allDay:
            return "All day"
        case .custom:
            return "custom"
        }
    }
}

/// A zero based enumeration with Monday as 0
public enum F4SDayOfWeek {
    
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
    
    /// Initializes a new instance from a zero-based day number (0 represents Monday, 1 Tuesday etc)
    public init?(zeroBasedDayNumber: Int) {
        switch zeroBasedDayNumber {
        case 0: self = F4SDayOfWeek.monday
        case 1: self = F4SDayOfWeek.tuesday
        case 2: self = F4SDayOfWeek.wednesday
        case 3: self = F4SDayOfWeek.thursday
        case 4: self = F4SDayOfWeek.friday
        case 5: self = F4SDayOfWeek.saturday
        case 6: self = F4SDayOfWeek.sunday
        default: return nil
        }
    }
    
    public var isWeekend: Bool {
        switch self {
        case .sunday, .saturday:
            return true
        default:
            return false
        }
    }
    
    public var longSymbol: String {
        switch self {
        case .monday:
            return "Monday"
        case .tuesday:
            return "Tuesday"
        case .wednesday:
            return "Wednesday"
        case .thursday:
            return "Thursday"
        case .friday:
            return "Friday"
        case .saturday:
            return "Saturday"
        case .sunday:
            return "Sunday"
        }
    }
    
    public var mediumSymbol: String {
        switch self {
        case .monday:
            return "Mon"
        case .tuesday:
            return "Tue"
        case .wednesday:
            return "Wed"
        case .thursday:
            return "Thu"
        case .friday:
            return "Fri"
        case .saturday:
            return "Sat"
        case .sunday:
            return "Sun"
        }
    }
    
    public var shortSymbol: String {
        switch self {
        case .monday:
            return "M"
        case .tuesday:
            return "T"
        case .wednesday:
            return "W"
        case .thursday:
            return "T"
        case .friday:
            return "F"
        case .saturday:
            return "S"
        case .sunday:
            return "S"
        }
    }
    
    public static func allDaysZeroBased() -> [F4SDayOfWeek] {
        var days = [F4SDayOfWeek]()
        for i in 0..<7 {
            days.append(F4SDayOfWeek(zeroBasedDayNumber: i)!)
        }
        return days
    }
    
    /// Initializes a new instance from a one-based day number (1 represents Sunday, 2 Monday, etc)
    public init?(traditionalDayNumber: Int) {
        switch traditionalDayNumber {
        case 2: self = F4SDayOfWeek.monday
        case 3: self = F4SDayOfWeek.tuesday
        case 4: self = F4SDayOfWeek.wednesday
        case 5: self = F4SDayOfWeek.thursday
        case 6: self = F4SDayOfWeek.friday
        case 7: self = F4SDayOfWeek.saturday
        case 1: self = F4SDayOfWeek.sunday
        default: return nil
        }
    }
    
    /// Returns a zero based value with Monday = 0 Tuesday = 1, etc
    var zeroBasedDayNumber: Int {
        switch self {
        case .sunday:
            return 6
        case .monday:
            return 0
        case .tuesday:
            return 1
        case .wednesday:
            return 2
        case .thursday:
            return 3
        case .friday:
            return 4
        case .saturday:
            return 5
        }
    }
    
    /// Returns the traditional day number (Sunday = 1, Monday 2, etc)
    var traditionalDayNumber: Int {
        switch self {
        case .sunday:
            return 1
        case .monday:
            return 2
        case .tuesday:
            return 3
        case .wednesday:
            return 4
        case .thursday:
            return 5
        case .friday:
            return 6
        case .saturday:
            return 7
        }
    }
}
