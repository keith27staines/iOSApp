
import Foundation
import WorkfinderCommon

protocol FreeTextEditorCoordinatorProtocol: class {
    func textEditorIsClosing()
}

class FreeTextEditorViewController: UIViewController {
    let fontSize: CGFloat = 17
    weak var coordinator: FreeTextEditorCoordinatorProtocol?
    let freeTextPicker: TextblockPicklist
    
    lazy var placeholderTextView: UITextView = {
        let placeholder = UITextView()
        view.backgroundColor = UIColor.lightGray
        placeholder.font = UIFont.italicSystemFont(ofSize: self.fontSize)
        placeholder.textColor = UIColor.lightGray
        placeholder.translatesAutoresizingMaskIntoConstraints = false
        placeholder.isUserInteractionEnabled = false
        return placeholder
    }()
    
    lazy var textContainer: UIView = {
        let view = UIView()
        view.addSubview(self.textView)
        view.addSubview(self.placeholderTextView)
        self.textView.fillSuperview()
        self.placeholderTextView.fillSuperview()
        return view
    }()
    
    lazy var textView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont.systemFont(ofSize: self.fontSize)
        textView.addSubview(self.placeholderTextView)
        textView.delegate = self
        textView.addDoneButton(title: "Done", target: self, selector: #selector(dismissKeyboard))
        return textView
    }()
    
    lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [self.textContainer])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        return stack
    }()
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        view.addSubview(stack)
        stack.fillSuperview()
        placeholderTextView.text = freeTextPicker.placeholder
        if freeTextPicker.selectedItems.count > 0 {
            textView.text = freeTextPicker.selectedItems[0].value ?? ""
        }
        placeholderTextView.isHidden = !textView.text.isEmpty
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if isMovingFromParent {
            freeTextPicker.selectedItems = [PicklistItemJson(uuid: "text", value: textView.text)]
            coordinator?.textEditorIsClosing()
        }
    }
    
    init(coordinator: FreeTextEditorCoordinatorProtocol,freeTextPicker: TextblockPicklist) {
        self.coordinator = coordinator
        self.freeTextPicker = freeTextPicker
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension FreeTextEditorViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderTextView.isHidden = !textView.text.isEmpty
    }
}

extension UITextView {
    func addDoneButton(title: String, target: Any, selector: Selector) {
        
        let toolBar = UIToolbar(frame: CGRect(x: 0.0,
                                              y: 0.0,
                                              width: UIScreen.main.bounds.size.width,
                                              height: 44.0))
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)//2
        let barButton = UIBarButtonItem(title: title, style: .plain, target: target, action: selector)//3
        toolBar.setItems([flexible, barButton], animated: false)
        self.inputAccessoryView = toolBar
    }
}
