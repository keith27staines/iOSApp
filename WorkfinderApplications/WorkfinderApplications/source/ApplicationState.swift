
/*
PENDING = "pending"
EXPIRED = "expired"
VIEWED = "viewed"
DECLINED = "declined"
SAVED = "saved"
OFFERED = "offered"
ACCEPTED = "accepted"
WITHDRAWN = "withdrawn"
*/

enum ApplicationState: String, Codable {
    case applied
    case pending
    case viewedByHost = "viewed"
    case applicationDeclined = "application declined"
    case offerMade = "offered"
    case offerAccepted = "accepted"
    case offerDeclined = "offer declined"
    case unknown
    
    var screenTitle: String {
        switch self {
        case .applied: return NSLocalizedString("Application submitted", comment: "")
        case .viewedByHost: return NSLocalizedString("Application viewed", comment: "")
        case .offerMade: return NSLocalizedString("Offer made", comment: "")
        case .offerAccepted: return NSLocalizedString("Offer accepted", comment: "")
        case .applicationDeclined: return NSLocalizedString("Application declined", comment: "")
        case .offerDeclined: return NSLocalizedString("Offer declined", comment: "")
        case .pending: return NSLocalizedString("Application submitted", comment: "")
        case .unknown: return NSLocalizedString("Status unknown", comment: "")
        }
    }
    
    var allowedActions: [ApplicationAction] {
        switch self {
        case .applied, .pending, .unknown:
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
        case .applied, .pending:
            return NSLocalizedString("You have submitted your application", comment: "")
        case .viewedByHost:
            return NSLocalizedString("The host has viewed your application", comment: "")
        case .applicationDeclined:
            return NSLocalizedString("The host has rejected your application", comment: "")
        case .offerMade:
            return NSLocalizedString("Congratulations you have been offered a placement", comment: "")
        case .offerAccepted:
            return NSLocalizedString("Congratulations you accepted this offer", comment: "")
        case .offerDeclined:
            return NSLocalizedString("You declined the offer of a placement", comment: "")
        case .unknown:
            return NSLocalizedString("Unable to obtain the status of this application", comment: "")
        }
    }
}
