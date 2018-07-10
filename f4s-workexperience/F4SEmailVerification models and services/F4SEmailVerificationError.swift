//
//  F4SEmailVerificationError.swift
//  AuthTest
//
//  Created by Keith Dev on 28/12/2017.
//  Copyright © 2017 F4S. All rights reserved.
//

import Foundation
import Auth0

public enum F4SEmailVerificationError : Error {
    case networkErrorSubmittingEmailForVerification
    case cientsideEmailFormatCheckFailed
    case serversideEmailFormatCheckFailed
    case networkErrorProcessingLink
    case codeEmailCombinationNotValid
    case unknownError
    
    public static func f4sError(for error: Error) -> F4SEmailVerificationError {
        if let f4s = error as? F4SEmailVerificationError {
            return f4s
        }
        if let authError = error as? AuthenticationError {
            switch authError.statusCode {
            case 400:
                return .serversideEmailFormatCheckFailed
            case 401:
                return .codeEmailCombinationNotValid
            default:
                return .unknownError
            }
        }
        return .unknownError
    }
}

// MARK:- titles for buttons and visibility
public extension F4SEmailVerificationError {
    
    var isPrimaryButtonVisible: Bool {
        switch self {
        case .networkErrorSubmittingEmailForVerification:
            return true
        case .cientsideEmailFormatCheckFailed:
            return true
        case .serversideEmailFormatCheckFailed:
            return true
        case .networkErrorProcessingLink:
            return true
        case .codeEmailCombinationNotValid:
            return true
        case .unknownError:
            return true
        }
    }
    
    var titleForPrimaryButton: String {
        switch self {
        case .networkErrorSubmittingEmailForVerification:
            return LocalizedStrings.ButtonTitles.retry
        case .cientsideEmailFormatCheckFailed:
            return LocalizedStrings.ButtonTitles.editEmail
        case .serversideEmailFormatCheckFailed:
            return LocalizedStrings.ButtonTitles.editEmail
        case .networkErrorProcessingLink:
            return LocalizedStrings.ButtonTitles.retry
        case .codeEmailCombinationNotValid:
            return LocalizedStrings.ButtonTitles.restart
        case .unknownError:
            return LocalizedStrings.ButtonTitles.restart
        }
    }

    var isSecondaryButtonVisible: Bool {
        switch self {
        case .networkErrorSubmittingEmailForVerification:
            return true
        case .cientsideEmailFormatCheckFailed:
            return true
        case .serversideEmailFormatCheckFailed:
            return true
        case .networkErrorProcessingLink:
            return true
        case .codeEmailCombinationNotValid:
            return true
        case .unknownError:
            return true
        }
    }
    
    
    var titleForSecondaryButton: String {
        switch self {
        case .networkErrorSubmittingEmailForVerification:
            return LocalizedStrings.ButtonTitles.cancel
        case .cientsideEmailFormatCheckFailed:
            return LocalizedStrings.ButtonTitles.cancel
        case .serversideEmailFormatCheckFailed:
            return LocalizedStrings.ButtonTitles.cancel
        case .networkErrorProcessingLink:
            return LocalizedStrings.ButtonTitles.cancel
        case .codeEmailCombinationNotValid:
            return LocalizedStrings.ButtonTitles.cancel
        case .unknownError:
            return LocalizedStrings.ButtonTitles.cancel
        }
    }
}


// MARK:- LocalizedDescriptions and corrective actions
public extension F4SEmailVerificationError {
    /// Returns a short localised description of the error
    var description: String {
        switch self {
        case .networkErrorSubmittingEmailForVerification:
            return LocalizedStrings.ErrorDescriptions.networkErrorSubmittingEmail
        case .cientsideEmailFormatCheckFailed, .serversideEmailFormatCheckFailed:
            return LocalizedStrings.ErrorDescriptions.emailFormatError
        case .networkErrorProcessingLink:
            return LocalizedStrings.ErrorDescriptions.networkErrorProcessingLink
        case .codeEmailCombinationNotValid:
            return LocalizedStrings.ErrorDescriptions.emailCodeCombinationInvalid
        case .unknownError:
            return LocalizedStrings.ErrorDescriptions.unknownError
        }
    }
    
    var correctiveAction: String {
        switch self {
        case .networkErrorSubmittingEmailForVerification:
            return LocalizedStrings.ErrorCorrectiveActions.networkErrorSubmittingEmail
        case .cientsideEmailFormatCheckFailed, .serversideEmailFormatCheckFailed:
            return LocalizedStrings.ErrorCorrectiveActions.emailFormatError
        case .networkErrorProcessingLink:
            return LocalizedStrings.ErrorCorrectiveActions.networkErrorProcessingLink
        case .codeEmailCombinationNotValid:
            return LocalizedStrings.ErrorCorrectiveActions.codeEmailCombinationInvalid
        case .unknownError:
            return LocalizedStrings.ErrorCorrectiveActions.unknownError
        }
    }
}