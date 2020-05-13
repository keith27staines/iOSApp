
enum OfferState {
    case open
    case accepted
    case declined
    case unknown
    
    init(applicationState: ApplicationState) {
        switch applicationState {
        case .offerMade: self = .open
        case .offerAccepted: self = .accepted
        case .offerDeclined: self = .declined
        default: self = .unknown
        }
    }
    
    var screenTitle: String {
        switch self {
        case .open: return "Offer made"
        case .accepted: return "Offer accepted"
        case .declined: return "Offer declined"
        case .unknown: return "Offer"
        }
    }
    
    var description: String {
        switch self {
        case .open: return "Congratulation you have been offered a placement"
        case .accepted: return "Congratulations you have accepted this placement"
        case .declined: return "You declined this offer"
        case .unknown: return "Offer"
        }
    }
}
