//
//  F4SDateHelper.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 03/08/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation


public struct F4SDateHelper {
    static public func unformattedAcceptDateStringToFormattedString(unformattedString: String?) -> String {
        let formattedString: String
        if let unformattedString = unformattedString {
            let endDate = F4SDateHelper.yyyyMMDD(string: unformattedString)
            formattedString = endDate?.asAcceptDateString() ?? unformattedString
        } else {
            formattedString = ""
        }
        return formattedString
    }
    
    static public func yyyyMMDD(string: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-DD"
        return dateFormatter.date(from: string)
    }
}

public extension Date {
    func asAcceptDateString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "DD MMM yyyy"
        return dateFormatter.string(from: self)
    }
}
