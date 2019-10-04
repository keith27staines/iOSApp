
import UIKit
import WorkfinderCommon
import WorkfinderUI

protocol  MotivationEditorViewControllerDelegate: class {
    
    func motivationEditorDidSetText(_ editor: MotivationTextModel)
    
}

protocol MotivationTextModelDelegate: class {
    func modelDidUpdate(_ model: MotivationTextModel)
}

class MotivationTextModel {
    weak var delegate: MotivationTextModelDelegate?
    private let repo: F4SMotivationRepositoryProtocol
    var option: MotivationTextOption {
        get { return repo.loadMotivationType() }
        set { repo.saveMotivationType(newValue) }
    }
    private var defaultText: String { return repo.loadDefaultMotivation() }
    private var customText: String {
        get { return repo.loadCustomMotivation() }
        set { repo.saveCustomMotivation(newValue) }
    }
    
    var text: String {
        get {
            switch option {
            case .standard: return defaultText
            case .custom: return customText
            }
        }
        set {
            customText = newValue
            self.delegate?.modelDidUpdate(self)
        }
    }
    let maxCharacters = 1000
    var characterCountText: String { return "\(text.count) of \(maxCharacters)" }
    var editingEnabled: Bool {
        return option == .custom ? true : false
    }
    
    init(repo: F4SMotivationRepositoryProtocol) {
        self.repo = repo
    }
    
    var selectedIndex: Int {
        get {
            switch option {
            case .standard: return 0
            case .custom: return 1
            }
        }
        set {
            self.option = newValue == 0 ? .standard : .custom
            self.delegate?.modelDidUpdate(self)
        }
    }
}

class MotivationEditorViewController: UIViewController, MotivationTextModelDelegate {

    weak var delegate: MotivationEditorViewControllerDelegate?
    
    var model: MotivationTextModel
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        updateFromModel()
        title = NSLocalizedString("Motivation", comment: "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardShown),
            name: UIResponder.keyboardDidShowNotification,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardHidden),
            name: UIResponder.keyboardDidHideNotification,
            object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func handleKeyboardShown(notification: Notification) {
        guard let keyboardRect = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey]
            as? NSValue else { return }

        let frameKeyboard = keyboardRect.cgRectValue

        motivationText.contentInset = UIEdgeInsets(
            top: 0.0,
            left: 0.0,
            bottom: frameKeyboard.size.height,
            right: 0.0
        )
        characterCountLabel.isHidden = false
        characterCountLabel.text = model.characterCountText
        view.layoutIfNeeded()
    }
    
    @objc func handleKeyboardHidden(notification: Notification) {
        motivationText.contentInset = .zero
        characterCountLabel.isHidden = true
        view.layoutIfNeeded()
    }
    
    func updateFromModel() {
        optionPicker.selectedSegmentIndex = model.selectedIndex
        motivationText.text = model.text
        motivationText.isEditable = model.editingEnabled
        characterCountLabel.text = model.characterCountText
    }
    
    func configureViews() {
        view.backgroundColor = UIColor.white
        view.addSubview(mainStack)
        mainStack.fillSuperview(padding: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
    }
    
    lazy var optionPicker: UISegmentedControl = {
        let view = UISegmentedControl(items: [NSLocalizedString("Default", comment: ""),NSLocalizedString("Custom", comment: "")])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(handleOptionPickerChange), for: UIControl.Event.valueChanged)
        return view
    }()
    
    @objc func handleOptionPickerChange() {
        model.selectedIndex = optionPicker.selectedSegmentIndex
    }
    
    @objc func handleTextChanged() {
        model.text = motivationText.text ?? ""
    }
    
    @objc func hideKeyboard() {
        motivationText.resignFirstResponder()
    }
    
    lazy var motivationText: UITextView = {
        let view = UITextView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.autocapitalizationType = .sentences
        view.autocorrectionType = .yes
        view.spellCheckingType = .yes
        view.textAlignment = .natural
        view.delegate = self
        view.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)
        view.inputAccessoryView = self.keyboardToolbar
        return view
    }()
    
    lazy var keyboardToolbar: UIToolbar = {
        let bar = UIToolbar()
        let done = UIBarButtonItem(
            barButtonSystemItem: UIBarButtonItem.SystemItem.done,
            target: self,
            action: #selector(hideKeyboard))
        let characters = UIBarButtonItem(customView: self.characterCountLabel)
        let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        bar.items = [characters, space, done]
        bar.sizeToFit()
        self.characterCountLabel.text = self.model.characterCountText
        self.characterCountLabel.frame.size = CGSize(width: 100, height: bar.frame.height)
        return bar
    }()
    
    lazy var characterCountLabel: UILabel = {
        return UILabel()
    }()
    
    lazy var mainStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [self.optionPicker, self.motivationText])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = 8
        stack.axis = .vertical
        return stack
    }()
    
    func modelDidUpdate(_ model: MotivationTextModel) {
        optionPicker.selectedSegmentIndex = model.selectedIndex
        motivationText.text = model.text
        motivationText.isEditable = model.editingEnabled
        delegate?.motivationEditorDidSetText(model)
    }
    
    init(delegate: MotivationEditorViewControllerDelegate, model: MotivationTextModel) {
        self.delegate = delegate
        self.model = model
        super.init(nibName: nil, bundle: nil)
        if #available(iOS 13.0, *) { overrideUserInterfaceStyle = .light }
        model.delegate = self
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
}

extension MotivationEditorViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        model.text = textView.text
        characterCountLabel.text = model.characterCountText
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars < model.maxCharacters
    }
}
