//
//  LocalizedStrings.swift
//  AuthTest
//
//  Created by Keith Dev on 28/12/2017.
//  Copyright © 2017 F4S. All rights reserved.
//

import Foundation

public struct LocalizedStrings {
    
    public struct ErrorDescriptions {
        static let networkErrorSubmittingEmail = NSLocalizedString(
            "No network connection",
            comment:"Describes the lack of network availability")

        static let networkErrorProcessingLink = NSLocalizedString(
            "No network connection",
            comment:"Describes the lack of network availability")

        static let emailFormatError = NSLocalizedString(
            "The email address is incorrectly formatted",
            comment:"Reports a format problem with an email address")
        
        static let emailCodeCombinationInvalid = NSLocalizedString(
            "Invalid email address or link",
            comment:"Reports that the email address/link combination was rejected")
        
        static let unknownError = NSLocalizedString(
            "An unexpected error has occurred",
            comment:"A catchall report for an error we don't understand")
    }
    
    public struct ErrorCorrectiveActions {
        static let networkErrorSubmittingEmail = NSLocalizedString(
        "We were unable to submit your email for verification due to a network error\n\nPlease make sure you have a good internet connection and try again",
        comment: "Give the user the corrective action for a bad internet connection when submitting their email address for verification")
        
        static let emailFormatError = NSLocalizedString(
            "Your email address seems to be incorrectly formatted\n\nPlease try again",
            comment: "Ask the user to correct their email address")
        
        static let networkErrorProcessingLink = NSLocalizedString(
            "We were unable to process the link do to a network error\nPlease make sure you have a good internet connection and try again",
            comment: "Give the user the corrective action for a bad internet connection when attempting to submit their linke for verification")
        
        static let codeEmailCombinationInvalid = NSLocalizedString(
            "We were unable to verify your email\nThis might be because there is an error in your email address or the link might have expired\nPlease ensure your email address is correct and try again",
            comment: "Give the user the corrective action for a failed verification attempt")
        
        static let unknownError = NSLocalizedString(
            "Please try again and contact us if this error keeps happening",
            comment: "Give the user guidance when an unexpected error occurs in the application")
    }
    
    public struct IntroductionStrings {
        static let start = NSLocalizedString("Please tell us your email address", comment: "Prompt the user to enter their email address")
        static let emailSent = NSLocalizedString("We have sent you a link so that we can verify your email address", comment: "Advise the user that we have sent them an email verification link")
        static let linkReceived = NSLocalizedString("Processing link", comment: "Advise the user that we are processing the link")
        static let verified = NSLocalizedString("Email verified", comment: "Advise the user that we have verified their email address")
        static let  previouslyVerified = NSLocalizedString("This is the verified email address we currently hold for you", comment: "Remind the user of their verified email address")
    }
    
    public struct FeedbackStrings {
        static let start = NSLocalizedString("We will send you a link so that we can verify your email address", comment: "Advise the user that we will send them an email verification link")
        
        static let emailSent = NSLocalizedString(
            "When the link arrives (it might take a minute or two) please open it on this device\n\nThis will enable us to complete the confirmation process",
            comment: "Advise the user to open the link in the email we sent them (we need them to do it on the ios device they started the process on)")
        
        static let linkReceived = NSLocalizedString(
            "Workfinder needs an internet connection to finish the process of verifying your email address",
            comment: "Advise the user that an internet connection is required to complete the process of verifying their email address")
        
        static let verified = NSLocalizedString(
            "We have verified your email address\n\nThank you!",
            comment: "Advise the user that we have verified their email address")
        
        static let  previouslyVerified = NSLocalizedString(
            "You can change to a different one now if you want to but we will need to verify it again",
            comment: "Ask the user if they want to change their email address")
    }
    
    public struct ButtonTitles {
        static let editEmail = NSLocalizedString("Edit email address", comment: "Instruct Workfinder to allow the user to change their email address")
        
        static let requestVerificationLink = NSLocalizedString("Send link", comment: "Instruct Workfinder to send a verification link")
        
        static let resendLink = NSLocalizedString("Resend link", comment: "Instruct Workfinder to resend the email verification link")
        
        static let processLink = NSLocalizedString("Process link", comment: "Request Workfinder to process the link it has received")
        
        static let next = NSLocalizedString("Continue", comment: "Tell Workfinder to continue with whatever workflow comes after email verification")
        
        static let restart = NSLocalizedString("Start again", comment: "Tell Workfinder to begin the email verification process from scratch")
        
        static let retry = NSLocalizedString("Try again", comment: "Tell Workfinder to retry the operation that failed")
        
        static let cancel = NSLocalizedString("Cancel", comment: "Tell Workfinder to stop trying to verify email address")
    }
}
