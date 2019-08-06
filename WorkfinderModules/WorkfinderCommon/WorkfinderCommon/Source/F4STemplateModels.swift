//
//  F4STemplateModels.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 19/06/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation

public struct F4STemplate: Codable {
    
    public let uuid: F4SUUID
    public let template: String
    public let blanks: [F4STemplateBlank]
    
    public init(uuid: String = "", template: String = "", blanks: [F4STemplateBlank] = []) {
        self.uuid = uuid
        self.template = template
        self.blanks = blanks
    }
    
    public func blankWithName(_ name: TemplateBlankName) -> F4STemplateBlank? {
        return blanks.first(where: { (blank) -> Bool in
            blank.name == name.rawValue
        })
    }
    
    public func blankWithName(_ name: String) -> F4STemplateBlank? {
        return blanks.first(where: { (blank) -> Bool in
            blank.name == name
        })
    }
}

public enum F4STemplateOptionType : String, Codable {
    case multiselect
    case select
    case date
}

public struct F4STemplateBlank : Codable {
    public var name: String
    public var placeholder: String
    public var optionType: F4STemplateOptionType
    public var maxChoices: Int
    public var choices: [F4SChoice]
    public var initialValue: String?
    
    public init(name: String = "", placeholder: String = "", optionType: F4STemplateOptionType = .select, maxChoices: Int = 0, choices: [F4SChoice] = [], initial: String? = nil) {
        self.name = name
        self.placeholder = placeholder
        self.optionType = optionType
        self.maxChoices = maxChoices
        self.choices = choices
        self.initialValue = initial
    }
    
    public mutating func removeChoiceWithUuid(_ uuid: F4SUUID) {
        guard let index = choices.firstIndex(where: { (choice) -> Bool in choice.uuid == uuid }) else { return }
        choices.remove(at: index)
    }
}

extension F4STemplateBlank {
    private enum CodingKeys : String, CodingKey {
        case name
        case placeholder
        case optionType = "option_type"
        case maxChoices = "max_choice"
        case choices = "option_choices"
        case initialValue = "initial"
    }
}

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

public enum TemplateBlankName: String {
    case personalAttributes = "attributes"
    case jobRole = "role"
    case employmentSkills = "skills"
    case startDate = "start_date"
    case endDate = "end_date"
}

public struct CoverLetterJson : Encodable {
    public init() {}
    public var placementUuid: F4SUUID?
    public var templateUuid: F4SUUID?
    public var userUuid: F4SUUID?
    public var companyUuid: F4SUUID?
    public var interests: [F4SUUID]?
    public var choices: [CoverLetterBlankJson]?
}

extension CoverLetterJson {
    private enum CodingKeys : String, CodingKey {
        case placementUuid = "uuid"
        case templateUuid = "coverletter_uuid"
        case userUuid = "user_uuid"
        case companyUuid = "company_uuid"
        case interests
        case choices = "coverletter_choices"
    }
}

public struct CoverLetterBlankJson : Encodable {
    public init() {}
    public var name: String?
    public var result: F4SJSONValue?
}
