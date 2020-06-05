
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
    case expired
    case viewedByHost = "viewed"
    case savedByHost = "saved"
    case applicationDeclined = "application declined"
    case offerMade = "offered"
    case offerAccepted = "accepted"
    case candidateWithdrew = "offer declined"
    case unknown
    
    var screenTitle: String {
        switch self {
        case .applied: return NSLocalizedString("Application submitted", comment: "")
        case .expired: return NSLocalizedString("Application expired", comment: "")
        case .viewedByHost: return NSLocalizedString("Application viewed", comment: "")
        case .savedByHost: return NSLocalizedString("Application viewed", comment: "")
        case .offerMade: return NSLocalizedString("Offer made", comment: "")
        case .offerAccepted: return NSLocalizedString("Offer accepted", comment: "")
        case .applicationDeclined: return NSLocalizedString("Application declined", comment: "")
        case .candidateWithdrew: return NSLocalizedString("Withdrawn", comment: "")
        case .unknown: return NSLocalizedString("Status unknown", comment: "")
        }
    }
    
    var allowedActions: [ApplicationAction] {
        switch self {
        case .applied, .unknown:
            return [.viewApplication]
        case .expired:
            return [.viewApplication]
        case .viewedByHost, .savedByHost:
            return [.viewApplication]
        case .applicationDeclined:
            return [.viewApplication]
        case .offerMade:
            return [.viewApplication, .viewOffer, .acceptOffer, .declineOffer]
        case .offerAccepted:
            return [.viewApplication, .viewOffer]
        case .candidateWithdrew:
            return [.viewApplication, .viewOffer]
        }
    }
    
    var description: String {
        switch self {
        case .applied:
            return NSLocalizedString("You have submitted your application", comment: "")
        case .expired:
            return NSLocalizedString("This application has expired", comment: "")
        case .viewedByHost, .savedByHost:
            return NSLocalizedString("The host has viewed your application", comment: "")
        case .applicationDeclined:
            return NSLocalizedString("The host has rejected your application", comment: "")
        case .offerMade:
            return NSLocalizedString("Congratulations you have been offered a placement", comment: "")
        case .offerAccepted:
            return NSLocalizedString("Congratulations you accepted this offer", comment: "")
        case .candidateWithdrew:
            return NSLocalizedString("You declined the offer of a placement", comment: "")
        case .unknown:
            return NSLocalizedString("Unable to obtain the status of this application", comment: "")
        }
    }
}