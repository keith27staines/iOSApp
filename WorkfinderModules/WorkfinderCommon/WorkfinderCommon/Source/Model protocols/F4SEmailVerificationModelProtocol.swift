
import Foundation

public protocol F4SEmailVerificationModelProtocol: class {
    var lastNonErrorState: F4SEmailVerificationState { get }
    var emailVerificationState: F4SEmailVerificationState { get }
    var verifiedEmail: String? { get }
    var emailSentForVerification: String?  { get }
    var didChangeState: ((_ oldValue: F4SEmailVerificationState, _ newValue: F4SEmailVerificationState) -> Void)? { get set }
    
    func basicEmailFormatValidator(email: String?) -> Bool
    func isEmailAddressVerified(email: String?) -> Bool
    func restart()
    func submitEmailForVerification(_ email: String, completion: @escaping (()->Void))
    func stagingBypassSetVerifiedEmail(email: String)
}



public enum F4SEmailVerificationState : Equatable {
    case start
    case emailSent(String)
    case linkReceived
    case verified
    case previouslyVerified
    case error(F4SEmailVerificationError)
    
    public static func ==(lhs: F4SEmailVerificationState, rhs: F4SEmailVerificationState) -> Bool {
        return String(describing: lhs) == String(describing:rhs)
    }
}

public enum F4SEmailVerificationError : Error {
    case networkNotAvailable
    case networkErrorSubmittingEmailForVerification
    case cientsideEmailFormatCheckFailed
    case serversideEmailFormatCheckFailed
    case networkErrorProcessingLink
    case codeEmailCombinationNotValid
    case unknownError
    
    public static func f4sError(for error: Error) -> F4SEmailVerificationError {
        if let f4s = error as? F4SEmailVerificationError { return f4s }
        
        switch error {
        case let error as EmailSubmissionError:
            switch error {
            case .client:
                return F4SEmailVerificationError.networkNotAvailable
            case .cientsideEmailFormatCheckFailed:
                return F4SEmailVerificationError.cientsideEmailFormatCheckFailed
            case .serversideEmailFormatCheckFailed:
                return F4SEmailVerificationError.serversideEmailFormatCheckFailed
            case .networkError(_):
                return F4SEmailVerificationError.networkErrorSubmittingEmailForVerification
            }
        
        case let error as CodeValidationError:
            switch error {
            case .client:
                return F4SEmailVerificationError.networkNotAvailable
            case .codeEmailCombinationNotValid:
                return F4SEmailVerificationError.codeEmailCombinationNotValid
            case .emailNotTheSame:
                return F4SEmailVerificationError.codeEmailCombinationNotValid
            case .networkError(_):
                return F4SEmailVerificationError.networkErrorProcessingLink
            }
        default: return .unknownError
        }
    }
}
