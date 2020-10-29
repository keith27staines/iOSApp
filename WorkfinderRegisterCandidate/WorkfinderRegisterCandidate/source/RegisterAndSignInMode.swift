
enum RegisterAndSignInMode {
    case register
    case signIn
    
    var screenTitle: String {
        switch self {
        case .register:
            return NSLocalizedString("Register", comment: "")
        case .signIn:
            return NSLocalizedString("Log in", comment: "")
        }
    }
    
    var screenHeadingText: String {
        switch self {
        case .register:
            return NSLocalizedString("Register", comment: "")
        case .signIn:
            return NSLocalizedString("Sign in", comment: "")
        }
    }
    
    var switchModeLabelText: String {
        switch self {
        case .register:
            return NSLocalizedString("Already have an account?", comment: "")
        case .signIn:
            return NSLocalizedString("Don't have an account?", comment: "")
        }
    }
    
    var switchModeActionText: String {
        switch self {
        case .register:
            return NSLocalizedString("Sign in", comment: "log in with your existing account here")
        case .signIn:
            return NSLocalizedString("Register", comment: "register for your user account here")
        }
    }
    
    var primaryActionButtonText: String {
        switch self {
        case .register:
            return NSLocalizedString("Register", comment: "register an account")
        case .signIn:
            return NSLocalizedString("Sign in", comment: "log into an account")
        }
    }
}
