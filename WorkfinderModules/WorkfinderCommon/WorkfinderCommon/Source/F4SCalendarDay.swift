import Foundation

public struct F4SCalendarDay : Equatable, Comparable {
    
    public static func <(lhs: F4SCalendarDay, rhs: F4SCalendarDay) -> Bool {
        return lhs.midday < rhs.midday
    }
    
    public static func ==(lhs: F4SCalendarDay, rhs: F4SCalendarDay) -> Bool {
        return lhs.midday == rhs.midday
    }
    
    public let midday: Date // midday
    let cal: F4SCalendar
    
    /// The date used as "today" when deciding if the current instance isToday, isInFuture, and isInPast
    var dateToday = Date()
    
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
    
    /// Returns true of the date represented by the current istance is equal
    /// to `dateToday`, otherwise false
    public var isToday: Bool {
        let today = F4SCalendarDay(cal: cal, date: dateToday)
        return self == today
    }
    
    /// Returns true if the date represented by the current instance is less
    /// than the `dateToday`
    public var isInPast: Bool {
        let today = F4SCalendarDay(cal: cal, date: dateToday)
        return self < today
    }
    
    /// Returns true if the date represented by the current instance is greater
    /// than the `dateToday`
    public var isInFuture: Bool {
        let today = F4SCalendarDay(cal: cal, date: dateToday)
        return self > today
    }
}
