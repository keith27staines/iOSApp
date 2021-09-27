
import UIKit
import WorkfinderUI

enum ApplicationState: String, Codable {
    case pending
    case expired
    case viewed
    case declined
    case saved
    case contacting
    case offered
    case accepted
    
    case interviewOffered = "interview offered"
    case interviewConfirmed = "interview confirmed"
    case interviewMeetingLinkAdded = "interview meeting link added"
    case interviewCompleted = "interview completed"
    case interviewDeclined = "interview declined"

    case withdrawn
    case cancelled
    case unroutable
    case unknown
    
    var displayName: String { screenTitle }
    
    init(string: String?) {
        if let state = ApplicationState.init(rawValue: string ?? "") {
            self = state
        } else {
            self = .unknown
        }
    }
    
    var capsuleColor: UIColor {
        switch self {
        case .pending: return WFColorPalette.dimmedYellow
        case .expired: return WFColorPalette.gray3
        case .viewed: return WFColorPalette.dimmedYellow
        case .declined: return WFColorPalette.gray3
        case .saved: return WFColorPalette.gray3
        case .contacting: return WFColorPalette.salmon
        case .offered: return WFColorPalette.salmon
        case .accepted: return WFColorPalette.graphicsGreen

        case .interviewOffered: return WFColorPalette.salmon
        case .interviewConfirmed: return WFColorPalette.dimmedYellow
        case .interviewMeetingLinkAdded: return WFColorPalette.graphicsGreen
        case .interviewCompleted: return WFColorPalette.dimmedYellow
        case .interviewDeclined: return WFColorPalette.gray3

        case .withdrawn: return WFColorPalette.gray3
        case .cancelled: return WFColorPalette.gray3
        case .unroutable: return WFColorPalette.gray3
        case .unknown: return WFColorPalette.gray3
        }
    }
    
    var screenTitle: String {
        switch self {
        case .pending: return "Waiting for host"
        case .expired: return "Unselected"
        case .viewed: return "Waiting for host"
        case .declined: return "Unselected"
        case .saved: return "Saved"
        case .contacting: return "Action Needed"
        case .offered: return "Placement Offered"
        case .accepted: return "Offer Accepted"
        case .interviewOffered: return "Interview Offered"
        case .interviewConfirmed: return "Interview Accepted"
        case .interviewMeetingLinkAdded: return "Interview Confirmed"
        case .interviewCompleted: return "Waiting for host"
        case .interviewDeclined: return "Interview Declined"
        case .withdrawn: return "Offer declined"
        case .cancelled: return "Offer Cancelled"
        case .unroutable: return "Unroutable"
        case .unknown: return "Unexpected State"
        }
    }
    
    var description: String {
        switch self {
        case .expired:
            return NSLocalizedString("This application has expired", comment: "")
        case .pending:
            return NSLocalizedString("Waiting for the host to respond", comment: "")
        case .contacting:
            return NSLocalizedString("Expect a call or email from this employer", comment: "")
        case .viewed, .saved:
            return NSLocalizedString("Waiting for the host to respond", comment: "")
        case .declined:
            return NSLocalizedString("Sorry, your application was not selected for progression by the host. Why not take this time to apply to other featured opportunities?", comment: "")
        case .offered:
            return NSLocalizedString("Congratulations! You have been offered a placement", comment: "")
        case .accepted:
            return NSLocalizedString("Congratulations! You accepted this offer", comment: "")
        case .withdrawn:
            return NSLocalizedString("You declined the offer of a placement", comment: "")
        case .cancelled:
            return NSLocalizedString("The host has cancelled their offer", comment: "")
        case .unknown:
            return NSLocalizedString("Unable to recognise the status of this application", comment: "")
        case .interviewOffered:
            return NSLocalizedString("You are being invited to interview", comment: "")
        case .interviewConfirmed:
            return NSLocalizedString("Your have accepted the host's invitation to interview", comment: "")
        case .interviewMeetingLinkAdded:
            return NSLocalizedString("A link for your interview has been added", comment: "")
        case .interviewCompleted:
            return NSLocalizedString("Waiting for the host to respond", comment: "")
        case .interviewDeclined:
            return NSLocalizedString("You declined your interview invitation", comment: "")
        case .unroutable:
            return NSLocalizedString("We haven't been able to contact the host", comment: "")
        }
    }
}
