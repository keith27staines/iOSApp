//
//  DataFixes.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 28/03/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation
import WorkfinderCommon
import WorkfinderApplyUseCase

public struct DataFixes {
    
    public func run() {
        moveUserUuidFromKeychainToUserDefaults()
        moveSelectedTemplateChoicesToUserDefaults()
    }
    
    private func moveUserUuidFromKeychainToUserDefaults() {
        F4SUser.dataFixMoveUUIDFromKeychainToUserDefaults()
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
