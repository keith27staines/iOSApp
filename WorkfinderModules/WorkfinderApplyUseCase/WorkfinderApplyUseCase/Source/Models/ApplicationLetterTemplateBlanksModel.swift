//
//  PopulatedBlanksModel.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 28/03/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation
import WorkfinderCommon

protocol ApplicationLetterTemplateBlanksModelProtocol : class {
    var template: F4STemplate? { get }
    @discardableResult func setTemplate(_ template: F4STemplate) -> Bool
    func populatedBlanks() -> [F4STemplateBlank]
    func templateBlankWithName(_ name: TemplateBlankName) -> F4STemplateBlank?
    func templateBlankWithName(_ name: String) -> F4STemplateBlank?
    func populatedBlankWithName(_ name: TemplateBlankName) -> F4STemplateBlank?
    func addOrReplacePopulatedBlanks(_ blanks: [F4STemplateBlank]) throws
    func addOrReplacePopulatedBlank(_ blank: F4STemplateBlank) throws
    func updateBlanksFor(firstDay: F4SCalendarDay?, lastDay: F4SCalendarDay?) 
}

class ApplicationLetterTemplateBlanksModel : ApplicationLetterTemplateBlanksModelProtocol {

    internal private (set) var template: F4STemplate?
    let store: LocalStorageProtocol
    
    enum WEXApplicationModelError : Error {
        case blankNameNotRecognised
    }
    
    init(store: LocalStorageProtocol, template: F4STemplate? = nil) {
        self.store = store
        self.template = template
    }
    
    func setTemplate(_ template: F4STemplate) -> Bool {
        guard self.template == nil else { return false }
        self.template = template
        let blanks = populatedBlanks()
        let cleansedBlanks = ApplicationLetterTemplateBlanksCleanser(templateBlanks: blanks).cleanse()
        try! addOrReplacePopulatedBlanks(cleansedBlanks)
        return true
    }
    
    func populatedBlanks() -> [F4STemplateBlank] {
        guard let data = store.value(key: LocalStore.Key.userPopulatedTemplateBlanksData) as? Data else { return [] }
        do {
            return try JSONDecoder().decode([F4STemplateBlank].self, from: data)
        } catch {
            return []
        }
    }
    
    func templateBlankWithName(_ name: TemplateBlankName) -> F4STemplateBlank? {
        return template?.blankWithName(name)
    }
    
    func templateBlankWithName(_ name: String) -> F4STemplateBlank? {
        return template?.blankWithName(name)
    }
    
    func populatedBlankWithName(_ name: TemplateBlankName) -> F4STemplateBlank? {
        return populatedBlanks().first(where: { (blank) -> Bool in
            return blank.name == name.rawValue
        })
    }
    
    func addOrReplacePopulatedBlanks(_ blanks: [F4STemplateBlank]) throws {
        try blanks.forEach { (blank) in try addOrReplacePopulatedBlank(blank) }
    }
    
    func addOrReplacePopulatedBlank(_ blank: F4STemplateBlank) throws {
        var blanks = populatedBlanks()
        guard let blankName = TemplateBlankName(rawValue: blank.name) else { throw WEXApplicationModelError.blankNameNotRecognised }
        blanks = removeBlankWithName(blankName, from: blanks)
        blanks.append(blank)
        save(blanks: blanks)
    }
    
    func updateBlanksFor(firstDay: F4SCalendarDay?, lastDay: F4SCalendarDay?) {
        let firstDateString = firstDay == nil ? "" : firstDay!.interval.start.dateToStringRfc3339()!
        let lastDateString = lastDay == nil ? "" : lastDay!.interval.start.dateToStringRfc3339()!
        let firstDayBlankName = TemplateBlankName.startDate
        let lastDayBlankName = TemplateBlankName.endDate
        
        var firstDayblank = populatedBlankWithName(firstDayBlankName) ?? F4STemplateBlank(name: TemplateBlankName.startDate.rawValue, choices: [F4SChoice(uuid: firstDateString)])
        var lastDayblank = populatedBlankWithName(lastDayBlankName) ?? F4STemplateBlank(name: TemplateBlankName.endDate.rawValue, choices: [F4SChoice(uuid: lastDateString)])
        
        firstDayblank.choices = [F4SChoice(uuid: firstDateString)]
        lastDayblank.choices = [F4SChoice(uuid: lastDateString)]
        try! addOrReplacePopulatedBlank(firstDayblank)
        try! addOrReplacePopulatedBlank(lastDayblank)
    }
    
    func save(blanks: [F4STemplateBlank]) {
        let data = try! JSONEncoder().encode(blanks)
        store.setValue(data, for: LocalStore.Key.userPopulatedTemplateBlanksData)
    }
    
    func removeBlankWithName(_ name: TemplateBlankName, from blanks: [F4STemplateBlank]) -> [F4STemplateBlank] {
        var blanks = blanks
        guard let index = indexOfBlank(name, in: blanks) else { return blanks }
        blanks.remove(at: index)
        return blanks
    }
    
    func indexOfBlank(_ name: TemplateBlankName, in blanks: [F4STemplateBlank]) -> Int? {
        return blanks.firstIndex(where: { (existingBlank) -> Bool in
            name.rawValue == existingBlank.name
        })
    }
}
