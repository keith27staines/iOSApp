
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
        case .offerMade: self = .hostOfferOpen
        case .offerAccepted: self = .candidateAccepted
        case .candidateWithdrew: self = .candidateWithdrew
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
        case .hostOfferOpen: return "Congratulation you have been offered a placement"
        case .candidateAccepted: return "Congratulations you have accepted this placement"
        case .candidateWithdrew: return "You declined this offer"
        case .unknown: return "Offer"
        }
    }
}
