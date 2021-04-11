//
//  NotificationPreferences.swift
//  WorkfinderCandidateProfile
//
//  Created by Keith Staines on 11/04/2021.
//

import Foundation

class NotificationPreferences {
    var isDirty: Bool = false
    var isEnabled: Bool = false
    var allowApplicationUpdates: Bool = true { didSet { isDirty = true } }
    var allowInterviewUpdates: Bool = true  { didSet { isDirty = true } }
    var allowRecommendations: Bool = true  { didSet { isDirty = true } }
    
    init() {}
    
    init(
        isDirty: Bool,
        isEnabled: Bool,
        allowApplicationUpdates: Bool,
        allowInterviewUpdates: Bool,
        allowRecommendations: Bool) {
        self.isDirty = isDirty
        self.isEnabled = isEnabled
        self.allowApplicationUpdates = allowApplicationUpdates
        self.allowInterviewUpdates = allowInterviewUpdates
        self.allowRecommendations = allowRecommendations
    }
}
