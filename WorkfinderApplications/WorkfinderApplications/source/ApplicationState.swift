enum ApplicationState: String {
    case applied
    case viewedByHost = "viewed"
    case applicationDeclined = "application declined"
    case offerMade = "offered"
    case offerAccepted = "accepted"
    case offerDeclined = "offer declined"
    
    var screenTitle: String {
        switch self {
        case .applied: return NSLocalizedString("Application submitted", comment: "")
        case .viewedByHost: return NSLocalizedString("Application viewed", comment: "")
        case .offerMade: return NSLocalizedString("Offer made", comment: "")
        case .offerAccepted: return NSLocalizedString("Offer accepted", comment: "")
        case .applicationDeclined: return NSLocalizedString("Application declined", comment: "")
        case .offerDeclined: return NSLocalizedString("Offer declined", comment: "")
        }
    }
    
    var allowedActions: [ApplicationAction] {
        switch self {
        case .applied:
            return [.viewApplication]
        case .viewedByHost:
            return [.viewApplication]
        case .applicationDeclined:
            return [.viewApplication]
        case .offerMade:
            return [.viewApplication, .viewOffer, .acceptOffer, .declineOffer]
        case .offerAccepted:
            return [.viewApplication, .viewOffer]
        case .offerDeclined:
            return [.viewApplication, .viewOffer]
        }
    }
    
    var description: String {
        switch self {
        case .applied:
            return NSLocalizedString("You have submitted your application", comment: "")
        case .viewedByHost:
            return NSLocalizedString("The host has viewed your application", comment: "")
        case .applicationDeclined:
            return NSLocalizedString("The host has declined your application", comment: "")
        case .offerMade:
            return NSLocalizedString("Congratulations you have been offered a placement", comment: "")
        case .offerAccepted:
            return NSLocalizedString("Congratulations you accepted this offer", comment: "")
        case .offerDeclined:
            return NSLocalizedString("You declined the offer of a placement", comment: "")
        }
    }
}
