
import Foundation
import WorkfinderCommon
import WorkfinderUI

protocol TextEditorCoordinatorProtocol: class {
    func textEditorIsClosing(text: String)
}

class TextEditorViewController: UIViewController {
    
    let maxWordCount: Int
    
    let fontSize: CGFloat = 17
    var text: String { return self.textView.text }
    let guidanceText: String
    let placeholderText: String
    weak var coordinator: TextEditorCoordinatorProtocol?
    
    lazy var placeholderTextView: UITextView = {
        let placeholder = UITextView()
        placeholder.backgroundColor = UIColor.white
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
    
    lazy var wordCountLabel: UILabel = {
        let label = UILabel()
        label.text = "200/ \(self.maxWordCount)"
        label.backgroundColor = UIColor.init(white: 0.8, alpha: 1)
        label.font = WorkfinderFonts.caption1
        label.textColor = WorkfinderColors.white
        label.textAlignment = .center
        label.layer.cornerRadius = 4
        label.sizeToFit()
        let fitSize = label.frame.width * 1.2
        label.widthAnchor.constraint(equalToConstant: fitSize).isActive = true
        label.text = "0/ \(self.maxWordCount)"
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
        textView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 8, left: 0, bottom: 40, right: 0))
        placeholder.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 8, left: 0, bottom: 40, right: 0))
        view.addSubview(self.wordCountLabel)
        self.wordCountLabel.anchor(top: nil, leading: nil, bottom: view.bottomAnchor, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 4, right: 8))
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
            self.textContainer
            ]
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
    
    var bottomConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        configureNavigationBar()
        configureViews()
    }
    
    func configureNavigationBar() {
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backButton
        styleNavigationController()
    }
    
    func configureViews() {
        view.backgroundColor = UIColor.white
        view.addSubview(stack)
        let guide = view.safeAreaLayoutGuide
        stack.anchor(top: guide.topAnchor, leading: guide.leadingAnchor, bottom: nil, trailing: guide.trailingAnchor, padding: UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 20))
        bottomConstraint = stack.bottomAnchor.constraint(equalTo: guide.bottomAnchor)
        bottomConstraint.constant = maxWordCount > 20 ? -20 : -view.frame.height/2 - 60
        bottomConstraint.isActive = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateWordCount()
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard maxWordCount > 20 else { return }
        let userInfo = notification.userInfo ?? [:]
        guard let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let height = (keyboardFrame.height + 20)
        bottomConstraint.constant = -height
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutSubviews()
        }) { (success) in
            self.scrollTextViewToBottom(textView: self.textView)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if isMovingFromParent { coordinator?.textEditorIsClosing(text: text) }
        NotificationCenter.default.removeObserver(self)
    }
    
    init(coordinator: TextEditorCoordinatorProtocol,
         editorTitle: String,
         guidanceText: String,
         placeholderText: String, maxWordCount: Int) {
        self.maxWordCount = maxWordCount
        self.coordinator = coordinator
        self.guidanceText = guidanceText
        self.placeholderText = placeholderText
        super.init(nibName: nil, bundle: nil)
    }
    
    func updateWordCount() {
        let words = wordCount(text: textView.text)
        wordCountLabel.text = "\(words)/ \(self.maxWordCount)"
    }
    
    func wordCount(text: String) -> Int {
        return text.split(separator: " ").count
    }
    
    func scrollTextViewToBottom(textView: UITextView) {
        if textView.text.count > 0 {
            let location = textView.text.count - 1
            let bottom = NSMakeRange(location, 1)
            textView.scrollRangeToVisible(bottom)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TextEditorViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderTextView.isHidden = !textView.text.isEmpty
        updateWordCount()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        placeholderTextView.isHidden = true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // get the current text, or use an empty string if that failed
        let currentText = textView.text ?? ""

        // attempt to read the range they are trying to change, or exit if we can't
        guard let stringRange = Range(range, in: currentText) else { return false }

        // add their new text to the existing text
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)

        return wordCount(text: updatedText) <= maxWordCount ? true : false
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
