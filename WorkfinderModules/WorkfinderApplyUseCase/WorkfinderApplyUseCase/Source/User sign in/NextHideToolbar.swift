import UIKit
import WorkfinderUI

class NextHideToolbar: UIToolbar {
    weak var textField: NextResponderTextField?
    func hideKeyboard() { textField?.resignFirstResponder() }
    
    @objc func nextTapped() {
        textField?.nextResponderField?.becomeFirstResponder()
    }
    @objc func hideKeyboardTapped() { hideKeyboard() }
    
    init(textField: NextResponderTextField, showNextButton: Bool) {
        self.textField = textField
        super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        barStyle = UIBarStyle.default
        items = []
        if showNextButton {
            items?.append(UIBarButtonItem(title: "Next field", style: .plain, target: self, action: #selector(nextTapped)))
        }
        items?.append(contentsOf: [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Hide keyboard", style: UIBarButtonItem.Style.plain, target: self, action: #selector(hideKeyboardTapped))
        ])
        sizeToFit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
