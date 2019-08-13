//
//  F4STemplate.swift
//  WorkfinderCommon
//
//  Created by Keith Dev on 06/08/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation

/// An F4STemplate represents a block of text that in not mutable except for some
/// fields (represented within the text by: "{{name}}") that are replaced either
/// by placeholder text of user selected text obtained from an F4STemplateBlank
/// with the same name
public struct F4STemplate: Codable {
    /// The UUID of the template
    public let uuid: F4SUUID
    /// The full text of the template
    public let template: String
    /// The mutable parts of the text
    public let blanks: [F4STemplateBlank]
    
    /// Initialises a new instance
    ///
    /// - Parameters:
    ///   - uuid: The UUID of the template
    ///   - template: A description of the template
    ///   - blanks: An array of F4STemplateBlank instances
    public init(uuid: String = "", template: String = "", blanks: [F4STemplateBlank] = []) {
        self.uuid = uuid
        self.template = template
        self.blanks = blanks
    }
    
    /// Returns the first blank in the template whose name matches the specified name
    ///
    /// - Parameter name: The name of the blank (editable field)
    /// - Returns: An F4STemplateBlank with name matching the specified name
    public func blankWithName(_ name: TemplateBlankName) -> F4STemplateBlank? {
        return blanks.first(where: { (blank) -> Bool in
            blank.name == name.rawValue
        })
    }
    
    /// Returns the first blank in the template whose name matches the specified name
    ///
    /// - Parameter name: The name of the blank (editable field)
    /// - Returns: An F4STemplateBlank with name matching the specified name
    public func blankWithName(_ name: String) -> F4STemplateBlank? {
        return blanks.first(where: { (blank) -> Bool in
            blank.name == name
        })
    }
}
