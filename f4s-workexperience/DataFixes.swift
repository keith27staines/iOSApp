//
//  DataFixes.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 28/03/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation
import CoreData
import WorkfinderCommon
import WorkfinderApplyUseCase

public struct DataFixes {
    
    public func run() {
        moveUserUuidFromKeychainToUserDefaults()
        moveSelectedTemplateChoicesToUserDefaults()
        moveUserRecordFromCoredataToLocalStore()
        nullifyPartnerIfInvalid()
    }
    
    /// If the partner uuid held in the local store isn't in one of the known
    /// good ones (currently "kown good" uuids are those in a hard coded list)
    /// then it should be deleted
    private func nullifyPartnerIfInvalid() {
        let localStore = LocalStore()
        guard let chosenPartnerUuid = localStore.value(key: LocalStore.Key.partnerID) as? F4SUUID else { return }
        
        if !F4SPartnersModel.hardCodedPartners().contains(where: { (partner) -> Bool in
            partner.uuid == chosenPartnerUuid
        }) {
            // remove invalid uuid from local store
            localStore.setValue(nil, for: LocalStore.Key.partnerID)
        }
        
    }
    
    private func moveUserUuidFromKeychainToUserDefaults() {
        F4SUser.dataFixMoveUUIDFromKeychainToUserDefaults()
    }
    
    private func moveUserRecordFromCoredataToLocalStore() {
        guard LocalStore().value(key: LocalStore.Key.user) == nil else {
            UserInfoDBOperations.sharedInstance.deleteUser()
            return
        }
        guard
            let userUuid = LocalStore().value(key: LocalStore.Key.userUuid) as? F4SUUID,
            let user = UserInfoDBOperations.sharedInstance.getUserInfo() else { return }
        user.updateUuid(uuid: userUuid)
        let repo = F4SUserRepository()
        repo.save(user: user)
    }
    
    private func moveSelectedTemplateChoicesToUserDefaults() {
        let populatedBlanksFromDB = TemplateChoiceDBOperations.sharedInstance.getSelectedTemplateBlanks()
        guard !populatedBlanksFromDB.isEmpty else { return }
        let blanksModel = ApplicationLetterTemplateBlanksModel(store: LocalStore())
        do {
            try blanksModel.addOrReplacePopulatedBlanks(populatedBlanksFromDB)
            let reloadedBlanks = blanksModel.populatedBlanks()
            try! TemplateChoiceDBOperations.sharedInstance.deleteAllTemplateChoices()
            print("Blanks from DB")
            print(populatedBlanksFromDB)
            print("Blanks moved to local store")
            print(reloadedBlanks)
        } catch {
            print("Error moving templates from coredata to local store \n\(error)")
        }
    }
}

///////////////////////////////////////////////////////////////
// MARK:- almost obsolete coredata operations
///////////////////////////////////////////////////////////////

fileprivate class UserInfoDBOperations {
    class var sharedInstance: UserInfoDBOperations {
        struct Static {
            static let instance: UserInfoDBOperations = UserInfoDBOperations()
        }
        return Static.instance
    }
    
    func getUserInfo() -> F4SUser? {
        guard let userUuid = F4SUser().uuid,
            let userInfoDB = UserInfoCoreDataManager.sharedInstance.getUserInfo(userUuid: userUuid) else {
                return nil
        }
        return F4SUser(userData: userInfoDB)
    }
    
    func deleteUser() {
        UserInfoCoreDataManager.sharedInstance.deleteUser()
    }
}


fileprivate class TemplateChoiceDBOperations {
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

fileprivate class TemplateChoiceCoreDataManager: CoreDataBaseManager {
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
    
    func deleteAllTemplateChoices() throws {
        try TemplateChoiceDB.deleteAllTemplateChoices(managedObjectContext)
    }
}

fileprivate class UserInfoCoreDataManager: CoreDataBaseManager {
    class var sharedInstance: UserInfoCoreDataManager {
        struct Static {
            static let instance: UserInfoCoreDataManager = UserInfoCoreDataManager()
        }
        return Static.instance
    }
    
    func getUserInfo(userUuid: String) -> UserInfoDB? {
        return UserInfoDB.getUserInfo(managedObjectContext,  userUuid: userUuid)
    }
    
    func deleteUser() {
        try! UserInfoDB.deleteUser(managedObjectContext)
    }
}
