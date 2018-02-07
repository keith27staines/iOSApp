//
//  TemplateChoiceDBOperations.swift
//  f4s-workexperience
//
//  Created by Timea Tivadar on 12/5/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import Foundation
import KeychainSwift

class TemplateChoiceDBOperations {
    class var sharedInstance: TemplateChoiceDBOperations {
        struct Static {
            static let instance: TemplateChoiceDBOperations = TemplateChoiceDBOperations()
        }
        return Static.instance
    }

    func saveTemplateChoice(name: String, choiceList: [String]) {
        let keychain = KeychainSwift()
        guard let userUuid = keychain.get(UserDefaultsKeys.userUuid) else {
            return
        }
        TemplateChoiceCoreDataManager.sharedInstance.saveTemplateChoiceToContext(name: name, userUuid: userUuid, choiceList: choiceList)
    }

    func getSelectedTemplateBlanks() -> [TemplateBlank] {
        let keychain = KeychainSwift()
        guard let userUuid = keychain.get(UserDefaultsKeys.userUuid) else {
            return []
        }
        let templateChoiceDBData = TemplateChoiceCoreDataManager.sharedInstance.getTemplateChoicesForUser(userUuid: userUuid)
        var templates: [TemplateBlank] = []
        for template in templateChoiceDBData {
            let temp = TemplateChoiceDBOperations.sharedInstance.getTemplateChoiceFromInterestDB(templateChoiceDB: template)
            templates.append(temp)
        }
        return templates
    }

    func getTemplateChoicesForCurrentUserWithName(name: String) -> TemplateBlank {
        let keychain = KeychainSwift()
        guard let userUuid = keychain.get(UserDefaultsKeys.userUuid),
            let templateChoiceDBData = TemplateChoiceCoreDataManager.sharedInstance.getTemplateChoicesForUserWithName(userUuid: userUuid, name: name) else {
            return TemplateBlank()
        }
        return TemplateChoiceDBOperations.sharedInstance.getTemplateChoiceFromInterestDB(templateChoiceDB: templateChoiceDBData)
    }

    func getAllTemplateChoices() -> [TemplateBlank] {
        let templateChoiceDBData = TemplateChoiceCoreDataManager.sharedInstance.getAllTemplateChoices()
        var templates: [TemplateBlank] = []
        for template in templateChoiceDBData {
            let temp = TemplateChoiceDBOperations.sharedInstance.getTemplateChoiceFromInterestDB(templateChoiceDB: template)
            templates.append(temp)
        }
        return templates
    }

    func removeTemplateWithName(name: String) {
        let keychain = KeychainSwift()
        guard let userUuid = keychain.get(UserDefaultsKeys.userUuid) else {
            return
        }
        TemplateChoiceCoreDataManager.sharedInstance.removeTemplateChoiceWithName(name: name, userUuid: userUuid)
    }

    fileprivate func getTemplateChoiceFromInterestDB(templateChoiceDB: TemplateChoiceDB) -> TemplateBlank {
        var temp: TemplateBlank = TemplateBlank()
        if let name = templateChoiceDB.name {
            temp.name = name
        }
        var choices: [Choice] = []
        for t in templateChoiceDB.getValueList() {
            choices.append(Choice(uuid: t))
        }
        temp.choices = choices
        return temp
    }
}
