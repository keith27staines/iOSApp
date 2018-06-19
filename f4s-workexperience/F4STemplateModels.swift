//
//  F4STemplateModels.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 19/06/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation

public struct F4STemplate: Codable {
    
    var uuid: F4SUUID
    var template: String
    var blanks: [F4STemplateBlank]
    
    init(uuid: String = "", template: String = "", blanks: [F4STemplateBlank] = []) {
        self.uuid = uuid
        self.template = template
        self.blanks = blanks
    }
}

enum F4STemplateOptionType : String, Codable {
    case multiselect
    case select
    case date
}

struct F4STemplateBlank : Codable {
    var name: String
    var placeholder: String
    var optionType: F4STemplateOptionType
    var maxChoices: Int
    var choices: [F4SChoice]
    var initialValue: String?
    
    init(name: String = "", placeholder: String = "", optionType: F4STemplateOptionType = .select, maxChoices: Int = 0, choices: [F4SChoice] = [], initial: String? = nil) {
        self.name = name
        self.placeholder = placeholder
        self.optionType = optionType
        self.maxChoices = maxChoices
        self.choices = choices
        self.initialValue = initial
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

struct F4SChoice : Codable {
    var uuid: String
    var value: String
    
    init(uuid: String = "", value: String = "") {
        self.uuid = uuid
        self.value = value
    }
    
    var uuidIsDate: Bool {
        return Date.dateFromRfc3339(string: uuid) == nil ? false : true
    }
}

extension F4SChoice {
    private enum CodingKeys : String, CodingKey {
        case uuid
        case value
    }
}
