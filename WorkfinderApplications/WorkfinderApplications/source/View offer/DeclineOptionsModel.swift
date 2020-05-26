
import UIKit
import WorkfinderUI

enum WithdrawReason: Int, CaseIterable {
    case haveAnotherOffer
    case datesUnsuitable
    case locationTooFar
    case other
    
    var buttonTitle: String {
        switch self {
        case .haveAnotherOffer: return NSLocalizedString("I have another offer", comment: "")
        case .datesUnsuitable: return NSLocalizedString("Cannot make those dates", comment: "")
        case .locationTooFar: return NSLocalizedString("Location is too far", comment: "")
        case .other: return NSLocalizedString("Other", comment: "")
        }
    }
}

class DeclineReasonsActionSheetFactory {
    
    var onDecline: (WithdrawReason) -> Void

    init(onDecline: @escaping (WithdrawReason) -> Void) {
        self.onDecline = onDecline
    }
    
    func makeDeclineOptionsAlert() -> UIAlertController {
        let alert = UIAlertController(
            title: "You're about to decline this placement. This action cannot be undone.",
            message: "What is your reason for declining?",
            preferredStyle: .actionSheet)
        sortedDeclineActions.forEach { action in alert.addAction(action) }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        return alert
    }
    var sortedDeclineActions: [UIAlertAction] {
        var actions = [UIAlertAction]()
        let sortedReasons = WithdrawReason.allCases.sorted { (reason1, reason2) -> Bool in
            reason1.rawValue < reason2.rawValue
        }
        for reason in sortedReasons {
            guard let action = declineActions[reason] else { continue }
            actions.append(action)
        }
        return actions
    }
    
    lazy var declineActions: [WithdrawReason: UIAlertAction] = {
        var declineActions = [WithdrawReason: UIAlertAction]()
        WithdrawReason.allCases.forEach { (reason) in
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
