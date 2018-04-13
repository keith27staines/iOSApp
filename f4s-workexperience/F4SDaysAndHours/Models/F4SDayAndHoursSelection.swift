//
//  F4SDayAndHoursSelection.swift
//  HoursPicker2
//
//  Created by Keith Dev on 27/03/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation

public struct F4SDayAndHourSelection {
    public var dayIsSelected: Bool
    public var dayOfWeek: F4SDayOfWeek
    public var hoursType: F4SHoursType
    public var contiguousPeriods: [DateInterval]?
}
