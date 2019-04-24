//
//  F4SCalendar.swift
//  HoursPicker2
//
//  Created by Keith Dev on 16/03/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation

/// Models the structures required to model a calendar
public class F4SCalendar {
    private let calendar: Calendar
    public let dateFormatter: DateFormatter
    private var displayMonths : [F4SDisplayableMonth]
    public private (set) var selectionStates: [Date:Int]
    
    public init() {
        var calendar = Calendar(identifier: .gregorian)
        dateFormatter = DateFormatter()
        calendar.firstWeekday = F4SDayOfWeek.monday.traditionalDayNumber
        self.calendar = calendar
        displayMonths = [F4SDisplayableMonth]()
        selectionStates = [Date:Int]()
        let displayMonth = F4SDisplayableMonth(cal: self, date: Date())
        displayMonths.append(displayMonth)
        
        expand(months: 11)
        clearAllSelections()
    }
    
    public enum Tap {
        case select
        case extend(fromDay:F4SCalendarDay)
        case clear
    }
    
    public var tap: Tap = .select
    
    public var firstDay: F4SCalendarDay? = nil
    public var lastDay: F4SCalendarDay? = nil
    
    /// The tree tap waltz is basically first tap selects start of period,
    /// second tap sets end of period (and selecte days between)
    /// third tap clears the selection
    /// There are some exceptions - first tap on an unavailable day does nothing
    /// second tapping on top of the first tap just clears the firs tap
    public func threeTapWaltz(day: F4SCalendarDay) {
        
        let tappedDate = day.midday
        
        switch tap {
        case .select:
            guard !day.isInPast else { return }
            firstDay = day
            lastDay = day
            selectionStates[tappedDate] = F4SExtendibleSelectionState.terminal.rawValue
            tap = Tap.extend(fromDay: day)
            return
        case .extend(let fromDay):
            guard !day.isInPast else { return }
            guard fromDay != day else {
                clearAllSelections()
                return
            }
            toggleSelection(day: day)
            lastDay = day
            orderFirstLastDays()
            tap = Tap.clear
        case .clear:
            clearAllSelections()
        }
    }
    
    public func setSelection(firstDay: F4SCalendarDay, lastDay: F4SCalendarDay) {
        clearAllSelections()
        threeTapWaltz(day: firstDay)
        if lastDay > firstDay {
            threeTapWaltz(day: lastDay)
        }
    }
    
    func orderFirstLastDays() {
        guard let first = firstDay, let last = lastDay else {
            return
        }
        if first <= last { return }
        firstDay = last
        lastDay = first
    }
    
    public func toggleSelection(day: F4SCalendarDay) {
        let oldStates = selectionStates
        let oldState = F4SExtendibleSelectionState(rawValue: oldStates[day.midday]!)!
        let targetDate = day.midday
        switch oldState {
        case .none:
            selectionStates[targetDate] = F4SExtendibleSelectionState.terminal.rawValue
        default:
            selectionStates[targetDate] = F4SExtendibleSelectionState.none.rawValue
        }
        var orderedValues = [(Date,F4SExtendibleSelectionState)]()
        for (date,value) in selectionStates {
            orderedValues.append((date,F4SExtendibleSelectionState(rawValue: value)!))
        }
        orderedValues = orderedValues.sorted(by: { (arg0, arg1) -> Bool in
            return arg0.0 < arg1.0
        })
        
        if oldState == .none {
            var lowestIndex: Int?
            var highestIndex: Int?
            var targetIndex: Int?
            for (index,value) in orderedValues.enumerated() {
                let state = value.1
                if value.0 == targetDate {
                    targetIndex = index
                } else {
                    if state != .none && value.0 != targetDate {
                        if lowestIndex == nil {
                            lowestIndex = index
                        }
                        highestIndex = index
                    }
                }
            }
            
            if lowestIndex != nil && targetIndex! < lowestIndex! {
                for i in targetIndex!..<lowestIndex! {
                    orderedValues[i].1 = .terminal
                }
            }
            
            if highestIndex != nil && targetIndex! > highestIndex! {
                for i in highestIndex!..<targetIndex! {
                    orderedValues[i].1 = .terminal
                }
            }
        }

        var correctedValues = orderedValues
        for (index,value) in orderedValues.enumerated() {
            if index == 0 { continue }
            if index == orderedValues.count - 1 { break }
            
            let date = value.0
            var state = value.1
            let previousDate = correctedValues[index-1].0
            var previousState = correctedValues[index-1].1
            if previousState == .terminal {
                print("")
            }
            previousState = correctedPreviousState(previousState: previousState, state: state)
            state = correctedState(previousState: previousState, state: state)
            correctedValues[index-1] = (previousDate,previousState)
            correctedValues[index] = (date, state)
        }
  
        for item in correctedValues {
            selectionStates[item.0] = item.1.rawValue
        }
        
    }
    
    private func correctedPreviousState(previousState: F4SExtendibleSelectionState, state: F4SExtendibleSelectionState) -> F4SExtendibleSelectionState {
        switch previousState {
        case .none:
            return .none
        case .terminal:
            switch state {
            case .none:
                return .terminal
            default:
                return .periodStart
            }
        case .periodStart:
            switch state {
            case .none:
                return .terminal
            case .terminal, .periodStart, .midPeriod, .periodEnd:
                return .periodStart
            }
        case .midPeriod:
            switch state {
            case .none:
                return .periodEnd
            default:
                return .midPeriod
            }
        case .periodEnd:
            switch state {
            case .none:
                return .periodEnd
            default:
                return .midPeriod
            }
        }
    }
    
    private func correctedState(previousState: F4SExtendibleSelectionState, state: F4SExtendibleSelectionState) -> F4SExtendibleSelectionState {
        switch state {
        case .none:
            return .none
        default:
            switch previousState {
            case .none:
                return .terminal
            default:
                return .periodEnd
            }
        }
    }
    
    public func clearAllSelections() {
        var day = displayMonths.first!.previousDisplayMonth().firstDay
        while day != displayMonths.last!.nextDisplayMonth().lastDay {
            selectionStates[day.midday] = F4SExtendibleSelectionState.none.rawValue
            day = day.nextDay
        }
        firstDay = nil
        lastDay = nil
        tap = Tap.select
    }
    
    public var numberOfDisplayableMonths: Int { return displayMonths.count }
    
    public func displayableMonth(index: Int) -> F4SDisplayableMonth {
        return displayMonths[index]
    }
    
    public func expand(months: Int) {
        var last = displayMonths.last!
        for _ in 0..<months {
            last = last.nextDisplayMonth()
            displayMonths.append(last)
        }
    }
    
    /// Returns a DateInterval that spans the calendar week containing the date
    public func intervalForWeekContaining(date: Date) -> DateInterval {
        return calendar.dateInterval(of: .weekOfMonth, for: date)!
    }
    
    /// Returns a DateInterval that spans the day containing the specified date
    public func intervalForDayContaining(date: Date) -> DateInterval {
        return calendar.dateInterval(of: .weekday, for: date)!
    }
    
    /// Returns the number of days in the month containing the specified date
    public func numberOfDaysInMonthContaining(date: Date) -> Int {
        let range = calendar.range(of: .day, in: .month, for: date)!
        return range.count
    }
    
    /// Returns the year number of the year that contains the specified date
    public func yearNumber(date: Date) -> Int {
        return calendar.component(.year, from: date)
    }
    
    /// Returns the month number of the month that contains the specified date
    public func monthNumber(date: Date) -> Int {
        return calendar.component(.month, from: date)
    }
    
    /// Returns the day of the month for the day containing the specified date
    public func dayNumber(date: Date) -> Int {
        return calendar.component(.day, from: date)
    }
    
    /// Returns the F4SDay that contains the specified date
    public func dayOfWeekContaining(date: Date) -> F4SDayOfWeek {
        return F4SDayOfWeek(traditionalDayNumber: calendar.component(.weekday, from: date))!
    }
    
    /// Returns the DateInterval of the day afer the day contaning the specified date
    public func nextDayAfterDayContaining(date: Date) -> DateInterval {
        let midday = middayOfDayContaining(date: date)
        let middayTomorrow = midday.addingTimeInterval(12*3600)
        return intervalForDayContaining(date:middayTomorrow)
    }
    
    /// Returns the DateInterval of the day before the day containing the specified date
    public func previousDayBeforeDayContaining(date: Date) -> DateInterval {
        let midday = middayOfDayContaining(date: date)
        let middayYesterday = midday.addingTimeInterval(-24*3600)
        return intervalForDayContaining(date:middayYesterday)
    }
    
    /// Returns the Date of the middle of the day containing the specified date
    public func middayOfDayContaining(date: Date) -> Date {
        let day = intervalForDayContaining(date: date)
        return day.start.addingTimeInterval(12*3600)
    }
}

public enum F4SCalendarDaySelectionType {
    case intermonthUnselected
    case intermonthSelected
    case unselectable
    case unselected
    case selected
    case todayUnselected
    case todaySelected
}

public enum F4SExtendibleSelectionState : Int {
    case none = 0
    case terminal = 1
    case periodStart = 2
    case periodEnd = 3
    case midPeriod = 4
}

