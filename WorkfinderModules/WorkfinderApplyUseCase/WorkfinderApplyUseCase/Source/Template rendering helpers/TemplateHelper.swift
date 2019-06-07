//
//  TemplateHelper.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 08/02/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation
import WorkfinderCommon

public struct TemplateHelper {
    
    /// Remove unavailable choices from the specified blanks by comparing them to the template blanks which
    /// are presumed to contain only available choices
    ///
    /// - parameter blanks: The list of blanks from which to remove unavailable choices
    /// - parameter templateBlanks: A presumed definitive list of blanks containing only available choices
    /// - returns: A list of blanks each containing only those selected choices that are available
    public static func removeUnavailableChoices(from blanks: [F4STemplateBlank], templateBlanks: [F4STemplateBlank]) -> [F4STemplateBlank] {
        var filteredBlanks = [F4STemplateBlank]()
        
        for selectedBlank in blanks {
            
            // Ensure that this blank exists in the template, otherwise we need to nothing
            guard let blankIndex = templateBlanks.firstIndex(where: { (templateBlank) -> Bool in
                templateBlank.name == selectedBlank.name
            }) else {
                filteredBlanks.append(selectedBlank)
                continue
            }
            let templateBlank = templateBlanks[blankIndex]
            
            // Remove any unavailable choices
            let filteredBlank = removeUnavailableChoices(from: selectedBlank, templateBlank: templateBlank)
            filteredBlanks.append(filteredBlank)
        }
        return filteredBlanks
    }
    
    /// Removes unavailable choices from a template blank
    ///
    /// - parameter blank: The blank containing potentially unavailable choices
    /// - parameter templateBlank: A presumed definitive blank containing only available choices
    /// - returns: A blank formed by removing unavailable choices from the original
    public static func removeUnavailableChoices(from blank: F4STemplateBlank, templateBlank: F4STemplateBlank) -> F4STemplateBlank {
        
        // if choices in blank don't have a match in the templateBlank, then
        // filter out those choices
        var filteredBlank = blank
        filteredBlank.choices = blank.choices.filter({ (choice) -> Bool in
            if templateBlank.choices.contains(where: { (templateChoice) -> Bool in
                templateChoice.uuid == choice.uuid
            }) {
                return true
            } else {
                return choice.uuidIsDate
            }
        })
        return filteredBlank
    }
}

