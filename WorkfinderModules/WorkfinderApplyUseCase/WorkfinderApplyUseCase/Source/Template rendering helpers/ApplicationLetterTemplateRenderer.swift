//
//  ApplicationLetterTemplateProcessor.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 25/03/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation
import Mustache
import WorkfinderCommon

enum TemplateCustomParse: String {
    case startPlaceholder = "{{startPlaceholder"
    case endPlaceholder = "endPlaceholder}}"
    case startSelected = "{{startSelected"
    case endSelected = "endSelected}}"
    case startBold = "{{startBold"
    case endBold = "endBold}}"
}

protocol TemplateChoicesLocalStorage {
    func removeChoiceWithName(_ name: String)
}

class ApplicationLetterTemplateRenderer {

    let currentTemplate: F4STemplate
    let companyName: String
    var selectedTemplateChoices: [F4STemplateBlank]
    var isComplete: Bool = false
    var availabilityWindow: WorkAvailabilityWindow?
    
    init(currentTemplate: F4STemplate,
         companyName: String,
         selectedTemplateChoices: [F4STemplateBlank]) {
        self.currentTemplate = currentTemplate
        self.companyName = companyName
        self.selectedTemplateChoices = selectedTemplateChoices
    }
    
    func populatedField(with string: String) -> String {
        return TemplateCustomParse.startSelected.rawValue + string + TemplateCustomParse.endSelected.rawValue
    }
    
    func renderTemplateToPlainString() throws -> String {
        isComplete = false
        let templateToRender = try Template(string: currentTemplate.template)
        
        var data: [String: Any] = [:]
        isComplete = true
        for templateBlank in currentTemplate.blanks {
            data[templateBlank.name] = dataForBlank(templateBlank)
        }
        
        data["company_name"] =
            TemplateCustomParse.startBold.rawValue +
            companyName +
            TemplateCustomParse.endBold.rawValue
        do {
            let renderingTemplate = try templateToRender.render(data)
            return renderingTemplate.htmlDecode()
        } catch {
            isComplete = false
            throw error
        }
    }
    
    private func dataForBlank(_ templateBlank: F4STemplateBlank) -> String {
        let placeholder = delimitedTextFrom(templateBlank.placeholder, asPopulated: false)
        guard let matchingSelectedBlank = findSelectedBlankMatching(templateBlank: templateBlank) else {
            isComplete = false
            return placeholder
        }
        switch matchingSelectedBlank.optionType {
        case .text:
            if let text = matchingSelectedBlank.choices.first?.value {
                return delimitedTextFrom(text, asPopulated: true)
            } else {
                isComplete = false
                return placeholder
            }
            
        default:
            let fillStrings = getFillStrings(selectedChoices: matchingSelectedBlank.choices, availableChoices: templateBlank.choices)
            
            if let grammaticalString = F4SGrammar.list(fillStrings)?.htmlDecode() {
                return delimitedTextFrom(grammaticalString, asPopulated: true)
            } else {
                isComplete = false
                return placeholder
            }
        }
    }
    
    private func delimitedTextFrom(_ text: String, asPopulated: Bool) -> String {
        switch asPopulated {
        case true:
            return TemplateCustomParse.startSelected.rawValue +
                   text +
                   TemplateCustomParse.endSelected.rawValue
        case false:
            return TemplateCustomParse.startPlaceholder.rawValue +
                   text +
                   TemplateCustomParse.endPlaceholder.rawValue
        }
    }
    
    private func findSelectedBlankMatching(templateBlank: F4STemplateBlank) -> F4STemplateBlank? {
        guard let indexOfSelectedBlank = selectedTemplateChoices.firstIndex(where: { (otherBlank) -> Bool in
            return templateBlank.name == otherBlank.name }) else { return nil }
        return selectedTemplateChoices[indexOfSelectedBlank]
    }
    
    private func getFillStrings(selectedChoices: [F4SChoice], availableChoices: [F4SChoice]) -> [String] {
        var fillStrings = [String]()
        for selectedChoice in selectedChoices {
            if let indexOfChoice = availableChoices.firstIndex(where: { $0.uuid == selectedChoice.uuid }) {
                fillStrings.append(availableChoices[indexOfChoice].value)
            } else {
                let dateFormatter = DateFormatter()
                dateFormatter.timeStyle = .none
                dateFormatter.dateFormat = "dd MMM yyyy"
                if let date = Date.dateFromRfc3339(string: selectedChoice.uuid) {
                    fillStrings.append(dateFormatter.string(from: date))
                }
            }
        }
        return fillStrings
    }
    
    private func getValueForUuid(choices: [F4SChoice], uuid: String) -> String {
        if let indexOfChoice = choices.firstIndex(where: { $0.uuid == uuid }) {
            return choices[indexOfChoice].value
        }
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateFormat = "dd MMM yyyy"
        if let date = Date.dateFromRfc3339(string: uuid) {
            return dateFormatter.string(from: date)
        }
        return uuid
    }
}




