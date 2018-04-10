//
//  F4SCalendarServiceJson.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 09/04/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation



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

/// Represents an extended period of availability
public struct F4SAvailabilityPeriodJson : Codable {
    public var start_date: String
    public var end_date: String
    public var day_time_info: [F4SDayTimeInfoJson]
}

/// Represents the day and time info
public typealias F4SDayTimeInfoJson = [String : String]



