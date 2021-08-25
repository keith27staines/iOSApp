
import UIKit
import WorkfinderUI

enum ApplicationState: String, Codable {
    case applied
    case expired
    case pending
    case contacting
    case viewed
    case declined
    case saved
    case offered
    case accepted
    case withdrawn
    case cancelled
    case unknown
    
    init(string: String?) {
        guard let string = string else {
            self = .unknown
            return
        }
        switch string {
        case "applied": self = .applied
        case "pending": self = .pending
        case "expired": self = .expired
        case "viewed": self = .viewed
        case "contacting": self = .contacting
        case "declined": self = .declined
        case "saved": self = .saved
        case "offered": self = .offered
        case "accepted": self = .accepted
        case "withdrawn": self = .withdrawn
        case "cancelled": self = .cancelled
        default:
            self = .unknown
        }
    }
    
    var capsuleColor: UIColor {
        switch self {
        case .applied: return UIColor(red: 66, green: 191, blue: 235)
        case .expired: return UIColor(red: 72, green: 39, blue: 128)
        case .pending: return UIColor(red: 66, green: 191, blue: 235)
        case .contacting: return UIColor(red: 255, green: 198, blue: 44)
        case .viewed: return UIColor(red: 66, green: 191, blue: 235)
        case .saved: return UIColor(red: 255, green: 198, blue: 44)
        case .declined: return UIColor(red: 72, green: 39, blue: 128)
        case .offered: return WorkfinderColors.primaryColor
        case .accepted: return WorkfinderColors.primaryColor
        case .withdrawn: return UIColor(red: 72, green: 39, blue: 128)
        case .cancelled: return UIColor(red: 72, green: 39, blue: 128)
        case .unknown: return UIColor.lightGray
        }
    }
    
    var screenTitle: String {
        switch self {
        case .applied: return NSLocalizedString("Application submitted", comment: "")
        case .expired: return NSLocalizedString("Application expired", comment: "")
        case .pending: return NSLocalizedString("Pending", comment: "")
        case .contacting: return NSLocalizedString("Contacting", comment: "")
        case .viewed: return NSLocalizedString("Application viewed", comment: "")
        case .saved: return NSLocalizedString("Application viewed", comment: "")
        case .offered: return NSLocalizedString("Offer made", comment: "")
        case .accepted: return NSLocalizedString("Offer accepted", comment: "")
        case .declined: return NSLocalizedString("Application declined", comment: "")
        case .withdrawn: return NSLocalizedString("Withdrawn", comment: "")
        case .cancelled: return NSLocalizedString("Cancelled", comment: "")
        case .unknown: return NSLocalizedString("Status unknown", comment: "")
        }
    }
    
    var allowedActions: [ApplicationAction] {
        switch self {
        case .applied, .pending ,.unknown:
            return [.viewApplication]
        case .expired:
            return [.viewApplication]
        case .viewed, .saved:
            return [.viewApplication]
        case .declined:
            return [.viewApplication]
        case .offered:
            return [.viewApplication, .viewOffer, .acceptOffer, .declineOffer]
        case .accepted:
            return [.viewApplication, .viewOffer]
        case .withdrawn:
            return [.viewApplication, .viewOffer]
        case .cancelled:
            return [.viewOffer]
        case .contacting:
            return [.viewApplication, .viewOffer]
        }
    }
    
    var description: String {
        switch self {
        case .applied:
            return NSLocalizedString("You have submitted your application", comment: "")
        case .expired:
            return NSLocalizedString("This application has expired", comment: "")
        case .pending:
            return NSLocalizedString("Pending", comment: "")
        case .contacting:
            return NSLocalizedString("Expect a call or email from this employer", comment: "")
        case .viewed, .saved:
            return NSLocalizedString("The host has viewed your application", comment: "")
        case .declined:
            return NSLocalizedString("Sorry, your application was not selected for progression by the host. Why not take this time to apply to other featured opportunities?", comment: "")
        case .offered:
            return NSLocalizedString("Congratulations! You have been offered a placement", comment: "")
        case .accepted:
            return NSLocalizedString("Congratulations! You accepted this offer", comment: "")
        case .withdrawn:
            return NSLocalizedString("You declined the offer of a placement", comment: "")
        case .cancelled:
            return NSLocalizedString("The host has cancelled this offer", comment: "")
        case .unknown:
            return NSLocalizedString("Unable to obtain the status of this application", comment: "")
        }
    }
}
