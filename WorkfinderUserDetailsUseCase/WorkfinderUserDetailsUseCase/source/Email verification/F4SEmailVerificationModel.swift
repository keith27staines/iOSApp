
import Foundation
import WorkfinderCommon

/// A state machine that controls the verification process for emails
public class F4SEmailVerificationModel {
    
    /// The last non-error state before transitioning to the current state
    public private (set) var lastNonErrorState: F4SEmailVerificationState
    
    /// The service required to initiate and complete email verification requests
    let emailVerificationService: EmailVerificationServiceProtocol
    
    /// Initialises a new instance
    public init(emailVerificationService: EmailVerificationServiceProtocol) {
        self.emailVerificationService = emailVerificationService
        lastNonErrorState = F4SEmailVerificationState.start
        emailVerificationState = .previouslyVerified
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
        emailVerificationService.cancel()
        emailVerificationState = .start
    }
    
    var submitEmailForVerificationRetryCount: Int = 0
    
    /// Verification is performed by sending an email to the specified address. The email contains a code or link which will, in turn, need to be submitted for final verification
    public func submitEmailForVerification(_ email: String, completion: @escaping (()->Void)) {
        emailVerificationService.start(onSuccess: { [weak self] (email) in
            guard let strongSelf = self else { return }
            strongSelf.submitEmailForVerificationRetryCount = 0
            strongSelf.emailVerificationState = .emailSent(email)
            print("Email verification requested for \(email)")
            completion()
            return
        }, onFailure: { [weak self] (email, verificationError) in
            guard let strongSelf = self else { return }
            strongSelf.submitEmailForVerificationRetryCount += 1
            if strongSelf.submitEmailForVerificationRetryCount < 5 {
                strongSelf.submitEmailForVerification(email, completion: completion)
                return
            }
            let f4sError = F4SEmailVerificationError.f4sError(for: verificationError)
            strongSelf.emailVerificationState = .error(f4sError)
            completion()
            return
        })
    }
    
    func authenticationClientId() -> String {
        switch __environment {
        case .staging:
            return "GP0piRmEoPLyKQJETNVjKdjhosvPGTw0"
        case .production:
            return "2LfjThv1qvdIZn7L09v5OwxhsW87k4Hf"
        }
    }
    
    /// Submits a verification code for validation
    public func submitVerificationCode(_ code: String, completion:  @escaping (()->Void)) {
        guard let emailSentForVerification = self.emailSentForVerification else {
            self.emailVerificationState = .error(F4SEmailVerificationError.codeEmailCombinationNotValid)
            return
        }
        
        emailVerificationService.verifyWithCode(email: emailSentForVerification, code: code, onSuccess: { [weak self] (email) in
            guard let strongSelf = self else { return }
            strongSelf.emailVerificationState = .verified
            strongSelf.submitEmailForVerificationRetryCount = 0
        }, onFailure: { [weak self] (email, verificationError) in
            guard let strongSelf = self else { return }
            strongSelf.submitEmailForVerificationRetryCount += 1
            if strongSelf.submitEmailForVerificationRetryCount < 5 {
                print("Verify code retry \(strongSelf.submitEmailForVerificationRetryCount)")
                strongSelf.submitVerificationCode(code, completion: completion)
                return
            }
            print("Failed to authenticate email \(emailSentForVerification) with error \(verificationError)")
            let f4sError = F4SEmailVerificationError.f4sError(for: verificationError)
            self?.emailVerificationState = .error(f4sError)
        })
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
            case .verified:
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
    static var localStore: LocalStorageProtocol = LocalStore()
    
    static public private (set) var emailSentForVerification: String? {
        get {
            return localStore.value(key: LocalStore.Key.emailSentForVerificationKey) as? String
        }
        set {
            localStore.setValue(newValue, for: LocalStore.Key.emailSentForVerificationKey)
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
    
    /// Checks the specified email to see if it matches the previously verified email
    public func isEmailAddressVerified(email: String?) -> Bool {
        return email == verifiedEmail
    }
    
    public func stagingBypassSetVerifiedEmail(email: String) {
        verifiedEmail = email
    }
    
    static public private (set) var verifiedEmail: String? {
        get {
            return localStore.value(key: LocalStore.Key.verifiedEmailKey) as? String
        }
        set {
            localStore.setValue(newValue, for: LocalStore.Key.verifiedEmailKey)
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
        if afterAtSubStrings.count < 2 { return false }
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

