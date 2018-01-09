//
//  F4SEmailVerificationModel.swift
//  AuthTest
//
//  Created by Keith Dev on 18/12/2017.
//  Copyright © 2017 F4S. All rights reserved.
//

import Foundation
import Auth0

/// A state machine that controls the verification process for emails
public class F4SEmailVerificationModel {
    /// The last non-error state before transitioning to the current state
    public private (set) var lastNonErrorState: F4SEmailVerificationState
    
    /// The type of passwordless authentication to use - either code or link
    public let passwordlessType: PasswordlessType
    
    /// Initialises a new instance
    public init() {
        lastNonErrorState = F4SEmailVerificationState.start
        emailVerificationState = .previouslyVerified
        passwordlessType = .iOSLink
        addNotificationHandlers()
        emailVerificationState = F4SEmailVerificationModel.verificationState()
        switch emailVerificationState {
        case .error(_):
            lastNonErrorState = .start
        default:
            lastNonErrorState = emailVerificationState
        }
    }
    
    /// Determines the verification state from data held on local store
    public static func verificationState() -> F4SEmailVerificationState {
        if verifiedEmail != nil {
            return .previouslyVerified
        }
        if let emailSentForVerification = emailSentForVerification {
            return .emailSent(emailSentForVerification)
        }
        return .start
    }

    /// Restarts the verification process
    public func restart() {
        emailVerificationState = .start
    }

    /// Verification is performed by sending an email to the specified address. The email contains a code or link which will, in turn, need to be submitted for final verification
    public func submitEmailForVerification(_ email: String, completion: @escaping (()->Void)) {
        Auth0
            .authentication()
            .startPasswordless(
                email: email,
                type: passwordlessType,
                connection: "email")
            .start { [weak self] res in
                DispatchQueue.main.async { [weak self] in
                    guard let strongSelf = self else { return }
                    switch res {
                    case .failure(let error):
                       let f4sError = F4SEmailVerificationError.f4sError(for: error)
                        strongSelf.emailVerificationState = .error(f4sError)
                        completion()
                        return
                    case .success:
                        strongSelf.emailVerificationState = .emailSent(email)
                        completion()
                        return
                    }
                }
        }
    }
    
    /// Submits a verification code for validation
    public func submitVerificationCode(_ code: String, completion:  @escaping (()->Void)) {
        guard let emailSentForVerification = self.emailSentForVerification else {
            self.emailVerificationState = .error(F4SEmailVerificationError.codeEmailCombinationNotValid)
            return
        }
        
        Auth0.authentication()
            .login(usernameOrEmail: emailSentForVerification,
                   password: code,
                   multifactorCode: nil,
                   connection: "email",
                   scope: "openid email",
                   parameters: [:])
            .start { result in
                DispatchQueue.main.async { [weak self] in
                    switch result {
                    case .success(let credentials):
                        let f4sCredentials = F4SCredentials(auth0Credentials: credentials)
                        self?.emailVerificationState = .verified(f4sCredentials)
                    case .failure(let error):
                        let f4sError = F4SEmailVerificationError.f4sError(for: error)
                        self?.emailVerificationState = .error(f4sError)
                    }
                    completion()
                }
        }
    }
    
    /// A callback to notify the owner of a state change
    public var didChangeState: ((_ oldValue: F4SEmailVerificationState, _ newValue: F4SEmailVerificationState) -> Void)? = nil
    
    /// Sets or gets the current state of the email verification
    public private (set) var emailVerificationState: F4SEmailVerificationState {
        didSet {
            guard oldValue != emailVerificationState else {
                return
            }
            
            if !emailVerificationState.isErrorState {
                lastNonErrorState = emailVerificationState
            }
            
            switch emailVerificationState {
            case .start:
                self.verifiedEmail = nil
                self.emailSentForVerification = nil
            case .emailSent(let email):
                emailSentForVerification = email
                verifiedEmail = nil
            case .linkReceived:
                break
            case .verified(_):
                verifiedEmail = emailSentForVerification
                emailSentForVerification = nil
            case .previouslyVerified:
                emailSentForVerification = nil
                break
            case .error(_):
                emailSentForVerification = nil
                verifiedEmail = nil
            }
            self.didChangeState?(oldValue, emailVerificationState)
        }
    }
    
    /// The email address to which the validation email was sent
    static public private (set) var emailSentForVerification: String? {
        get {
            return UserDefaults.standard.string(forKey: emailSentForVerificationKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: emailSentForVerificationKey)
        }
    }
    
    public private (set) var emailSentForVerification: String? {
        get {
            return F4SEmailVerificationModel.emailSentForVerification
        }
        set {
            F4SEmailVerificationModel.emailSentForVerification = newValue
        }
    }
    
    /// The verified email address
    static public private (set) var verifiedEmail: String? {
        get {
            return UserDefaults.standard.string(forKey: verifiedEmailKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: verifiedEmailKey)
        }
    }
    
    public private (set) var verifiedEmail: String? {
        get {
            return F4SEmailVerificationModel.verifiedEmail
        }
        set {
            F4SEmailVerificationModel.verifiedEmail = newValue
        }
    }
    
    //MARK:- Keys used for storing info in UserDefaults
    private static let verifiedEmailKey = "verifiedEmailKey"
    private static let emailSentForVerificationKey = "emailSentForVerificationKey"
}


// MARK:- Notification handling
extension F4SEmailVerificationModel {
    /// adds handlers for notifications
    private func addNotificationHandlers() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.verificationCodeRecieved, object: nil, queue: nil) { [weak self] (notification) in
            self?.notificationReceived(notification)
        }
    }
    
    /// handles notifications, tests them to see if they contain magic links for authentication, and if so extracts the code in the link and submits it for verification
    func notificationReceived(_ notification: Notification) {
        switch emailVerificationState {
        case .emailSent(_):
            if let url: URL = notification.userInfo?["url"] as? URL,
               let code = F4SAuth0MagicLinkInterpreter.passcode(from: url) {
                submitVerificationCode(code) {}
            }
        default:
            return
        }
    }
}

// MARK:- Input validators
extension F4SEmailVerificationModel {
    /// Performs basic client-side checks on the specified email addresses
    public func basicEmailFormatValidator(email: String?) -> Bool {
        guard let email = email else { return false }
        let strings = email.split(separator: "@")
        if strings.count != 2 { return false }
        if strings[0].isEmpty { return false }
        if strings[1].isEmpty { return false }
        let afterAtString = strings[1]
        let afterAtSubStrings = afterAtString.split(separator: ".")
        if afterAtSubStrings.count != 2 { return false }
        if afterAtSubStrings[0].isEmpty { return false }
        if afterAtSubStrings[1].isEmpty { return false }
        return true
    }
    
    /// Performs basic client-side checks on the verification code
    public func basicVerificationCodeValidator(code: String?) -> Bool {
        guard let code = code else { return false }
        if code.isEmpty { return false }
        return true
    }
}

