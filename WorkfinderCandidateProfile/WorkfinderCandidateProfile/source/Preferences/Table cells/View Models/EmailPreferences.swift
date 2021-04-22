//
//  EmailPreferences.swift
//  WorkfinderCandidateProfile
//
//  Created by Keith Staines on 11/04/2021.
//

import Foundation
import WorkfinderCommon

class EmailPreferences {
    var isDirty: Bool = false
    var isEnabled: Bool = true
    weak var preferencesPresenter: PreferencesPresenter?
    
    var updateMarketingPreference: (newValue: Bool, completion: (Error?) -> Void)?
    var allowMarketingEmails: Bool = true { didSet { isDirty = true } }
    
    func setMarketingEmailPreference(allow: Bool, completion: @escaping (Error?) -> Void) {
        preferencesPresenter?.updateMarketingEmailPreference(newValue: allow) { [weak self] optionalError in
            self?.allowMarketingEmails = allow
            completion(optionalError)
        }
    }
    
    init() {}
    
    init(isDirty: Bool,
         isEnabled: Bool,
         allowMarketingEmails: Bool,
         preferencesPresenter: PreferencesPresenter) {
        self.isDirty = isDirty
        self.isEnabled = isEnabled
        self.allowMarketingEmails = allowMarketingEmails
        self.preferencesPresenter = preferencesPresenter
    }
}
