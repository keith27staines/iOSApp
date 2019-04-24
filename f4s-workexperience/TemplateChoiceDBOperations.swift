//
//  TemplateChoiceDBOperations.swift
//  f4s-workexperience
//
//  Created by Timea Tivadar on 12/5/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import Foundation
import WorkfinderCommon
import WorkfinderApplyUseCase

class TemplateChoiceDBOperations {
    class var sharedInstance: TemplateChoiceDBOperations {
        struct Static {
            static let instance: TemplateChoiceDBOperations = TemplateChoiceDBOperations()
        }
        return Static.instance
    }

    func saveTemplateChoice(name: String, choiceList: [String]) {
        guard let userUuid = F4SUser().uuid else {
            return
        }
        TemplateChoiceCoreDataManager.sharedInstance.saveTemplateChoiceToContext(name: name, userUuid: userUuid, choiceList: choiceList)
    }

    func getSelectedTemplateBlanks() -> [F4STemplateBlank] {
        guard let userUuid = F4SUser().uuid else {
            return []
        }
        let templateChoiceDBData = TemplateChoiceCoreDataManager.sharedInstance.getTemplateChoicesForUser(userUuid: userUuid)
        var templates: [F4STemplateBlank] = []
        for template in templateChoiceDBData {
            let temp = TemplateChoiceDBOperations.sharedInstance.getTemplateChoiceFromInterestDB(templateChoiceDB: template)
            templates.append(temp)
        }
        return templates
    }

    func getTemplateChoicesForCurrentUserWithName(name: String) -> F4STemplateBlank {
        guard let userUuid = F4SUser().uuid,
            let templateChoiceDBData = TemplateChoiceCoreDataManager.sharedInstance.getTemplateChoicesForUserWithName(userUuid: userUuid, name: name) else {
            return F4STemplateBlank()
        }
        return TemplateChoiceDBOperations.sharedInstance.getTemplateChoiceFromInterestDB(templateChoiceDB: templateChoiceDBData)
    }

    func getAllTemplateChoices() -> [F4STemplateBlank] {
        let templateChoiceDBData = TemplateChoiceCoreDataManager.sharedInstance.getAllTemplateChoices()
        var templates: [F4STemplateBlank] = []
        for template in templateChoiceDBData {
            let temp = TemplateChoiceDBOperations.sharedInstance.getTemplateChoiceFromInterestDB(templateChoiceDB: template)
            templates.append(temp)
        }
        return templates
    }

    func removeTemplateWithName(name: String) {
        guard let userUuid = F4SUser().uuid else {
            return
        }
        TemplateChoiceCoreDataManager.sharedInstance.removeTemplateChoiceWithName(name: name, userUuid: userUuid)
    }
    
    func deleteAllTemplateChoices() throws {
        try TemplateChoiceCoreDataManager.sharedInstance.deleteAllTemplateChoices()
    }

    fileprivate func getTemplateChoiceFromInterestDB(templateChoiceDB: TemplateChoiceDB) -> F4STemplateBlank {
        var templateBlank: F4STemplateBlank = F4STemplateBlank()
        if var name = templateChoiceDB.name {
            if name == "job_role" {
                name = "role"
            }
            templateBlank.name = name
        }
        var choices: [F4SChoice] = []
        for t in templateChoiceDB.getValueList() {
            choices.append(F4SChoice(uuid: t))
        }
        templateBlank.choices = choices
        return templateBlank
    }
}
