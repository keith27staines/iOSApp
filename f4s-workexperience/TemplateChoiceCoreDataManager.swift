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
        TemplateChoiceDB.createInManagedObjectContext(managedObjectContext, name: name, userUuid: userUuid, listOfChoice: choiceList)
        save()
    }

    func getTemplateChoicesForUserWithName(userUuid: String, name: String) -> TemplateChoiceDB? {
        return TemplateChoiceDB.getTemplatesForUserWithName(managedObjectContext, userUuid: userUuid, name: name)
    }

    func getTemplateChoicesForUser(userUuid: String) -> [TemplateChoiceDB] {
        return TemplateChoiceDB.getTemplatesForUser(managedObjectContext, userUuid: userUuid)
    }

    func getAllTemplateChoices() -> [TemplateChoiceDB] {
        return TemplateChoiceDB.getAllTemplateChoices(managedObjectContext)
    }

    func removeTemplateChoiceWithName(name: String, userUuid: String) {
        TemplateChoiceDB.removeTemplateChoiceWithNameForUser(managedObjectContext, name: name, userUuid: userUuid)
        save()
    }
}
