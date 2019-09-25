import Foundation

public enum CodeValidationError : Error {
    case client
    case codeEmailCombinationNotValid
    case emailNotTheSame
    case networkError(Int)
    
    public static func codeValidationError(from httpStatusCode: Int) -> CodeValidationError? {
        guard httpStatusCode != 200 else { return nil }
        switch httpStatusCode {
        case 401: return CodeValidationError.codeEmailCombinationNotValid
        default: return CodeValidationError.networkError(httpStatusCode)
        }
    }
}

public enum EmailSubmissionError : Error {
    case client
    case cientsideEmailFormatCheckFailed
    case serversideEmailFormatCheckFailed
    case networkError(Int)
    
    public static func emailSubmissionError(from httpStatusCode: Int) -> EmailSubmissionError? {
        guard httpStatusCode != 200 else { return nil }
        switch httpStatusCode {
        case 400: return EmailSubmissionError.serversideEmailFormatCheckFailed
        default: return networkError(httpStatusCode)
        }
    }
}
