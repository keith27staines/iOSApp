import UIKit
import WorkfinderUI

class NextHideToolbar: UIToolbar {
    weak var textField: NextResponderTextField?
    var hideKeyboard: () -> Void
    
    @objc func nextTapped() {
        textField?.nextResponderField?.becomeFirstResponder()
    }
    @objc func hideKeyboardTapped() { hideKeyboard() }
    
    init(textField: NextResponderTextField, hideKeyboard: @escaping () -> Void) {
        self.hideKeyboard = hideKeyboard
        self.textField = textField
        super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        barStyle = UIBarStyle.default
        items = [
            UIBarButtonItem(title: "Next field", style: .plain, target: self, action: #selector(nextTapped)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Hide keyboard", style: UIBarButtonItem.Style.plain, target: self, action: #selector(hideKeyboardTapped))]
        sizeToFit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
