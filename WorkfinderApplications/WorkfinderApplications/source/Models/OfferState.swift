
enum OfferState {
    case hostOfferOpen
    case candidateAccepted
    case candidateWithdrew
    case unknown
    
    var serverState: String {
        switch self {
        case .hostOfferOpen: return "offered"
        case .candidateAccepted: return "accepted"
        case .candidateWithdrew: return "withdrawn"
        case .unknown: return "unknown"
        }
    }
    
    init(applicationState: ApplicationState) {
        switch applicationState {
        case .offered: self = .hostOfferOpen
        case .accepted: self = .candidateAccepted
        case .withdrawn: self = .candidateWithdrew
        default: self = .unknown
        }
    }
    
    var screenTitle: String {
        switch self {
        case .hostOfferOpen: return "Offer made"
        case .candidateAccepted: return "Offer accepted"
        case .candidateWithdrew: return "Offer declined"
        case .unknown: return "Offer"
        }
    }
    
    var description: String {
        switch self {
        case .hostOfferOpen: return "Congratulations! You have been offered a placement!"
        case .candidateAccepted: return "Congratulations! You have accepted this placement!"
        case .candidateWithdrew: return "You declined this offer"
        case .unknown: return "Offer"
        }
    }
}
