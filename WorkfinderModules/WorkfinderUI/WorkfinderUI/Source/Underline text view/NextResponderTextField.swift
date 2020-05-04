//
//import UIKit
//
//
//open class NextResponderTextField: UITextField {
//
//    /// Represents the next field. It can be any responder.
//    /// If it is UIButton and enabled then the button will be tapped.
//    /// If it is UIButton and disabled then the keyboard will be dismissed.
//    /// If it is another implementation, it becomes first responder.
//    @IBOutlet open weak var nextResponderField: UIResponder?
//
//    /**
//     Creates a new view with the passed coder.
//     :param: aDecoder The a decoder
//     :returns: the created new view.
//     */
//    public required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        setUp()
//    }
//
//    /**
//     Creates a new view with the passed frame.
//     :param: frame The frame
//     :returns: the created new view.
//     */
//    public override init(frame: CGRect) {
//        super.init(frame: frame)
//        setUp()
//    }
//
//    private func setUp() {
//        addTarget(self, action: #selector(actionKeyboardButtonTapped(sender:)), for: .editingDidEndOnExit)
//    }
//    
//    open override var canBecomeFirstResponder: Bool { return true }
//
//    @objc private func actionKeyboardButtonTapped(sender _: UITextField) {
//        switch nextResponderField {
//        case let button as UIButton where button.isEnabled:
//            button.sendActions(for: .touchUpInside)
//        case .some(let responder):
//            responder.becomeFirstResponder()
//            
//        default:
//            resignFirstResponder()
//        }
//    }
//}
