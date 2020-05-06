
import Foundation
import WorkfinderCommon

protocol TextEditorCoordinatorProtocol: class {
    func textEditorIsClosing(text: String)
}

class TextEditorViewController: UIViewController {
    let fontSize: CGFloat = 17
    var text: String { return self.textView.text }
    let guidanceText: String
    let placeholderText: String
    weak var coordinator: TextEditorCoordinatorProtocol?
    
    lazy var placeholderTextView: UITextView = {
        let placeholder = UITextView()
        placeholder.backgroundColor = UIColor.init(white: 0.97, alpha: 1)
        placeholder.font = UIFont.italicSystemFont(ofSize: self.fontSize)
        placeholder.textColor = UIColor.lightGray
        placeholder.translatesAutoresizingMaskIntoConstraints = false
        placeholder.isUserInteractionEnabled = false
        placeholder.text = self.placeholderText
        placeholder.isUserInteractionEnabled = false
        return placeholder
    }()
    
    lazy var guidanceLabel: UILabel = {
        let label = UILabel()
        label.text = self.guidanceText
        label.numberOfLines = 0
        return label
    }()
    
    lazy var textContainer: UIView = {
        let textView = self.textView
        let placeholder = self.placeholderTextView
        let view = UIView()
        view.addSubview(textView)
        view.addSubview(placeholder)
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 1
        textView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
        placeholder.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
        return view
    }()
    
    lazy var textView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont.systemFont(ofSize: self.fontSize)
        textView.delegate = self
        textView.addDoneButton(title: "Done", target: self, selector: #selector(dismissKeyboard))
        return textView
    }()
    
    lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            self.guidanceLabel,
            self.textContainer]
        )
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = 8
        stack.axis = .vertical
        return stack
    }()
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor.white
        view.addSubview(stack)
        let guide = view.safeAreaLayoutGuide
        stack.anchor(top: guide.topAnchor, leading: guide.leadingAnchor, bottom: guide.bottomAnchor, trailing: guide.trailingAnchor, padding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if isMovingFromParent { coordinator?.textEditorIsClosing(text: text) }
    }
    
    init(coordinator: TextEditorCoordinatorProtocol, guidanceText: String, placeholderText: String) {
        self.coordinator = coordinator
        self.guidanceText = guidanceText
        self.placeholderText = placeholderText
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TextEditorViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderTextView.isHidden = !textView.text.isEmpty
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        placeholderTextView.isHidden = true
    }
}

extension UITextView {
    func addDoneButton(title: String, target: Any, selector: Selector) {
        
        let toolBar = UIToolbar(frame: CGRect(x: 0.0,
                                              y: 0.0,
                                              width: UIScreen.main.bounds.size.width,
                                              height: 44.0))
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let barButton = UIBarButtonItem(title: title, style: .plain, target: target, action: selector)
        toolBar.setItems([flexible, barButton], animated: false)
        self.inputAccessoryView = toolBar
    }
}
