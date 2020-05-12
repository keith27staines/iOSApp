enum ApplicationState {
    case viewed
    case declined
    
    var screenTitle: String {
        switch self {
        case .viewed: return "Application viewed"
        case .declined: return "Application declined"
        }
    }
    
    var description: String {
        switch self {
        case .viewed: return NSLocalizedString("The host has declined your applicatin", comment: "")
        case .declined: return "The host has declined your application"
        }
    }
}
