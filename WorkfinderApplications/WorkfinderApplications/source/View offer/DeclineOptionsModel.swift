
import UIKit
import WorkfinderUI

enum DeclineReason: Int, CaseIterable {
    case haveAnotherOffer
    case datesUnsuitable
    case locationTooFar
    case other
    
    var buttonTitle: String {
        switch self {
        case .haveAnotherOffer: return NSLocalizedString("I have another offer", comment: "")
        case .datesUnsuitable: return NSLocalizedString("Cannot make those dates", comment: "")
        case .locationTooFar: return "Location is too far"
        case .other: return "Other"
        }
    }
}

class DeclineReasonsActionSheetFactory {
    
    var onDecline: (DeclineReason) -> Void

    init(onDecline: @escaping (DeclineReason) -> Void) {
        self.onDecline = onDecline
    }
    
    func makeDeclineOptionsAlert() -> UIAlertController {
        let alert = UIAlertController(
            title: "You're about to decline this placement. This action cannot be undone.",
            message: "What is your reason for declining?",
            preferredStyle: .actionSheet)
        declineActions.forEach { (declineAction) in
            alert.addAction(declineAction.value)
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        return alert
    }
    
    lazy var declineActions: [DeclineReason: UIAlertAction] = {
        var declineActions = [DeclineReason: UIAlertAction]()
        let sortedReasons =  DeclineReason.allCases.sorted { (reason1, reason2) -> Bool in
            reason1.rawValue > reason2.rawValue
        }
        sortedReasons.forEach { (reason) in
            let alertAction = UIAlertAction(
                title: reason.buttonTitle, style: .destructive,
                handler: self.handleAction)
            declineActions[reason] = alertAction
        }
        return declineActions
    }()
    
    func handleAction(_ action: UIAlertAction) {
        guard let declineAction = (declineActions.first { (item) -> Bool in
            item.value === action
        }) else { return }
        onDecline(declineAction.key)
    }
}
