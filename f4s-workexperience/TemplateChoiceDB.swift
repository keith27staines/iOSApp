//
//  TemplateChoiceDB.swift
//  f4s-workexperience
//
//  Created by Timea Tivadar on 12/5/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import Foundation
import CoreData

@objc(TemplateChoiceDB)
class TemplateChoiceDB: NSManagedObject {

    @NSManaged var name: String?
    @NSManaged var value: NSData?
    @NSManaged var userUuid: String?

    func setValueList(list: [String]) {
        self.value = NSKeyedArchiver.archivedData(withRootObject: list) as NSData?
    }

    func getValueList() -> [String] {
        guard let data = self.value as? Data, let stringData = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String] else {
            return []
        }
        return stringData
    }

    @discardableResult
    class func createInManagedObjectContext(_ moc: NSManagedObjectContext, name: String, userUuid: String, listOfChoice: [String]) -> TemplateChoiceDB? {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest<NSFetchRequestResult>(entityName: "TemplateChoice")

        let predicate = NSPredicate(format: "name == %@ && userUuid == %@", name, userUuid)
        fetchRequest.predicate = predicate
        guard let fetchResult = (try? moc.fetch(fetchRequest)) as? [TemplateChoiceDB] else {
            return nil
        }

        if fetchResult.count == 0 {
            guard let newItem = NSEntityDescription.insertNewObject(forEntityName: "TemplateChoice", into: moc) as? TemplateChoiceDB else {
                return nil
            }
            newItem.name = name
            newItem.setValueList(list: listOfChoice)
            newItem.userUuid = userUuid
            return newItem
        } else {
            fetchResult[0].name = name
            fetchResult[0].setValueList(list: listOfChoice)
            fetchResult[0].userUuid = userUuid
            return fetchResult[0]
        }
    }

    class func getTemplatesForUser(_ moc: NSManagedObjectContext, userUuid: String) -> [TemplateChoiceDB] {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest<NSFetchRequestResult>(entityName: "TemplateChoice")

        let predicate = NSPredicate(format: "userUuid == %@", userUuid)
        fetchRequest.predicate = predicate

        guard let fetchResult = (try? moc.fetch(fetchRequest)) as? [TemplateChoiceDB], !fetchResult.isEmpty else {
            return []
        }

        return fetchResult
    }

    class func getTemplatesForUserWithName(_ moc: NSManagedObjectContext, userUuid: String, name: String) -> TemplateChoiceDB? {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest<NSFetchRequestResult>(entityName: "TemplateChoice")

        let predicate = NSPredicate(format: "userUuid == %@ && name == %@", userUuid, name)
        fetchRequest.predicate = predicate

        guard let fetchResult = (try? moc.fetch(fetchRequest)) as? [TemplateChoiceDB], !fetchResult.isEmpty else {
            return nil
        }

        return fetchResult[0]
    }

    class func getAllTemplateChoices(_ moc: NSManagedObjectContext) -> [TemplateChoiceDB] {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest<NSFetchRequestResult>(entityName: "TemplateChoice")

        guard let fetchResult = (try? moc.fetch(fetchRequest)) as? [TemplateChoiceDB], !fetchResult.isEmpty else {
            return []
        }

        return fetchResult
    }

    class func removeTemplateChoiceWithNameForUser(_ moc: NSManagedObjectContext, name: String, userUuid: String) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest<NSFetchRequestResult>(entityName: "TemplateChoice")

        let predicate = NSPredicate(format: "userUuid == %@ && name == %@", userUuid, name)
        fetchRequest.predicate = predicate

        guard let fetchResult = (try? moc.fetch(fetchRequest)) as? [TemplateChoiceDB], !fetchResult.isEmpty else {
            return
        }
        moc.delete(fetchResult[0])
    }
}
