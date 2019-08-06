//
//  F4SChoice.swift
//  WorkfinderCommon
//
//  Created by Keith Dev on 06/08/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation

/// An instance of F4SChoice represents a value selected by the YP to be inserted
/// into a template blank, such as occurs in a covering letter template or email
/// template
public struct F4SChoice : Codable {
    /// A UUID representing a specific value chosen by the YP to fill a blank in a template
    /// (Note there is a "WTF" here - the UUID is a string representing a date when the blank being filled represents a date
    public var uuid: String
    
    /// The string to be filled into the template blank representing the YP's choice
    public var value: String
    
    /// Initialises a new instance
    ///
    /// - Parameters:
    ///   - uuid: Either a genuine UUID if the choice doesn't represent a date or a date string if it does
    ///   - value: The string respresentation of the choice to be inserted into the template blank
    public init(uuid: String = "", value: String = "") {
        self.uuid = uuid
        self.value = value
    }
    
    /// Returns true iff the uuid string is a date in Rfc3339 form
    public var uuidIsDate: Bool {
        return Date.dateFromRfc3339(string: uuid) == nil ? false : true
    }
}

extension F4SChoice {
    private enum CodingKeys : String, CodingKey {
        case uuid
        case value
    }
}
