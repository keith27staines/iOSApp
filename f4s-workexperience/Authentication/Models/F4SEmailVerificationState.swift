//
//  F4SEmailVerificationState.swift
//  AuthTest
//
//  Created by Keith Dev on 28/12/2017.
//  Copyright © 2017 F4S. All rights reserved.
//

import Foundation

public enum F4SEmailVerificationState : Equatable {
    case start
    case emailSent(String)
    case linkReceived
    case verified(F4SCredentials)
    case previouslyVerified
    case error(F4SEmailVerificationError)
    
    public static func ==(lhs: F4SEmailVerificationState, rhs: F4SEmailVerificationState) -> Bool {
        return String(describing: lhs) == String(describing:rhs)
    }
}

// MARK:- Utility methods
public extension F4SEmailVerificationState {
    var isErrorState: Bool {
        switch self {
        case .error(_):
            return true
        default:
            return false
        }
    }
}

// MARK:- control visibility and titles
public extension F4SEmailVerificationState {
    
    var isPrimaryButtonVisible: Bool { return true }
    var isPrimaryButtonEnabled: Bool { return self.isPrimaryButtonVisible }
    var isEMailFieldVisible: Bool { return true }
    var isEmailFieldEnabled: Bool {
        switch self {
        case .start:
            return true
        default:
            return false
        }
    }
    
    var isSecondaryButtonEnabled: Bool { return self.isSecondaryButtonVisible }
    var isSecondaryButtonVisible: Bool {
        switch self {
        case .start:
            return true
        case .emailSent(_):
            return true
        case .linkReceived:
            return true
        case .verified(_):
            return true
        case .previouslyVerified:
            return true
        case .error(_):
            return true
        }
    }
    
    var titleForPrimary: String {

        switch self {
        case .start:
            return LocalizedStrings.ButtonTitles.requestVerificationLink
        case .emailSent(_):
            return LocalizedStrings.ButtonTitles.editEmail
        case .linkReceived:
            return LocalizedStrings.ButtonTitles.processLink
        case .verified(_):
            return LocalizedStrings.ButtonTitles.next
        case .previouslyVerified:
            return LocalizedStrings.ButtonTitles.next
        case .error(let error):
            return error.titleForPrimaryButton
        }
    }
    
    var titleForSecondary: String {
        return ""
    }
}

// MARK:- Title and feedback text
public extension F4SEmailVerificationState {
    var introductionString: String? {
        switch self {
        case .start:
            return LocalizedStrings.IntroductionStrings.start
        case .emailSent(_):
            return LocalizedStrings.IntroductionStrings.emailSent
        case .linkReceived:
            return LocalizedStrings.IntroductionStrings.linkReceived
        case .verified(_):
            return LocalizedStrings.IntroductionStrings.verified
        case .previouslyVerified:
            return LocalizedStrings.IntroductionStrings.previouslyVerified
        case .error(_):
            return nil
        }
    }
    
    var feedbackString: String {
        switch self {
        case .start:
            return LocalizedStrings.FeedbackStrings.start
        case .emailSent(_):
            return LocalizedStrings.FeedbackStrings.emailSent
        case .linkReceived:
            return LocalizedStrings.FeedbackStrings.linkReceived
        case .verified(_):
            return LocalizedStrings.FeedbackStrings.verified
        case .previouslyVerified:
            return LocalizedStrings.FeedbackStrings.previouslyVerified
        case .error(let error):
            return "\(error.description) \n\(error.correctiveAction)"
        }
    }
}

