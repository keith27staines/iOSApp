//
//  ApplicationLetterChoicesCleanser.swift
//  WorkfinderApplyUseCase
//
//  Created by Keith Dev on 26/03/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation
import WorkfinderCommon

class ApplicationLetterTemplateBlanksCleanser {
    
    private var templateBlanks: [F4STemplateBlank]
    
    init(templateBlanks: [F4STemplateBlank]) {
        self.templateBlanks = templateBlanks
    }
    
    func cleanse() -> [F4STemplateBlank] {
        removeInvalidDateFields()
        return templateBlanks
    }
    
    func removeInvalidDateFields() {
        let availability = getWorkAvailabilityWindow()
        if availability.status != .valid {
            removeStartDate()
            removeEndDate()
        }
    }
    
    private func removeStartDate() {
        if let index = indexForAttribute(TemplateBlankName.startDate) {
            templateBlanks.remove(at: index)
        }
    }
    
    private func removeEndDate() {
        if let index = indexForAttribute(TemplateBlankName.endDate) {
            templateBlanks.remove(at: index)
        }
    }
    
    func getWorkAvailabilityWindow() -> WorkAvailabilityWindow {
        let startDate: Date? = getStartDate()
        let endDate: Date? = getEndDate()
        let now = Date()
        return WorkAvailabilityWindow(
            startDay: startDate,
            endDay: endDate,
            submission: now)
    }
    
    func getStartDate() -> Date? {
        guard let index = indexForAttribute(TemplateBlankName.startDate) else {
            return nil
        }
        guard let choice = self.templateBlanks[index].choices.first else {
            return nil
        }
        return Date.dateFromRfc3339(string: choice.uuid)
    }
    
    func getEndDate() -> Date? {
        guard let index = indexForAttribute(TemplateBlankName.endDate) else {
            return nil
        }
        guard let choice = self.templateBlanks[index].choices.first else {
            return nil
        }
        return Date.dateFromRfc3339(string: choice.uuid)
    }
    
    func indexForAttribute(_ attribute: TemplateBlankName) -> Int? {
        return self.templateBlanks.firstIndex(where: { $0.name == attribute.rawValue })
    }
}
