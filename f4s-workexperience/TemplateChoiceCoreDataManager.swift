//
//  TemplateChoiceCoreDataManager.swift
//  f4s-workexperience
//
//  Created by Timea Tivadar on 12/5/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import Foundation
import CoreData

class TemplateChoiceCoreDataManager: CoreDataBaseManager {
    class var sharedInstance: TemplateChoiceCoreDataManager {
        struct Static {
            static let instance: TemplateChoiceCoreDataManager = TemplateChoiceCoreDataManager()
        }
        return Static.instance
    }

    func saveTemplateChoiceToContext(name: String, userUuid: String, choiceList: [String]) {
        guard let managedObjectCont = self.managedObjectContext else {
            return
        }
        TemplateChoiceDB.createInManagedObjectContext(managedObjectCont, name: name, userUuid: userUuid, listOfChoice: choiceList)
        save()
    }

    func getTemplateChoicesForUserWithName(userUuid: String, name: String) -> TemplateChoiceDB? {
        guard let managedObjectCont = self.managedObjectContext else {
            return nil
        }
        return TemplateChoiceDB.getTemplatesForUserWithName(managedObjectCont, userUuid: userUuid, name: name)
    }

    func getTemplateChoicesForUser(userUuid: String) -> [TemplateChoiceDB] {
        guard let managedObjectCont = self.managedObjectContext else {
            return []
        }
        return TemplateChoiceDB.getTemplatesForUser(managedObjectCont, userUuid: userUuid)
    }

    func getAllTemplateChoices() -> [TemplateChoiceDB] {
        guard let managedObjectCont = self.managedObjectContext else {
            return []
        }
        return TemplateChoiceDB.getAllTemplateChoices(managedObjectCont)
    }

    func removeTemplateChoiceWithName(name: String, userUuid: String) {
        guard let managedObjectCont = self.managedObjectContext else {
            return
        }
        TemplateChoiceDB.removeTemplateChoiceWithNameForUser(managedObjectCont, name: name, userUuid: userUuid)
        save()
    }
}
