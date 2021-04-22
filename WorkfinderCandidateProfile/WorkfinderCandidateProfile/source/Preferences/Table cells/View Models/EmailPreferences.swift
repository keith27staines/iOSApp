//
//  EmailPreferences.swift
//  WorkfinderCandidateProfile
//
//  Created by Keith Staines on 11/04/2021.
//

import Foundation

class EmailPreferences {
    var isDirty: Bool = false
    var isEnabled: Bool = true
    
    func setMarketingEmailPreference(allow: Bool, completion: @escaping (Error) -> Void) {
        //allowMarketingEmails = allow
    }
    var allowMarketingEmails: Bool = true { didSet { isDirty = true } }
    
    init() {}
    
    init(isDirty: Bool, isEnabled: Bool, allowMarketingEmails: Bool) {
        self.isDirty = isDirty
        self.isEnabled = isEnabled
        self.allowMarketingEmails = allowMarketingEmails
    }
}
