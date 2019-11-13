
import UIKit
import WorkfinderCommon
import WorkfinderUI

protocol  MotivationEditorViewControllerDelegate: class {
    
    func motivationEditorDidSetText(_ editor: MotivationTextModel)
    
}

class MotivationEditorViewController: UIViewController, MotivationTextModelDelegate {

    weak var delegate: MotivationEditorViewControllerDelegate?
    
    var model: MotivationTextModel
    weak var log: F4SAnalyticsAndDebugging?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        title = NSLocalizedString("Motivation", comment: "")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateFromModel()
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
    
    override func viewDidAppear(_ animated: Bool) {
        model.selectedIndex = optionPicker.selectedSegmentIndex
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupNavigationBar() {
        let image = UIImage(named: "backArrow")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: UIBarButtonItem.Style.plain, target: self, action: #selector(complete))
    }
    
    @objc func complete() {
        navigationController?.popViewController(animated: true)
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
        keyboardToolbar.isHidden = false
        view.layoutIfNeeded()
    }
    
    @objc func handleKeyboardHidden(notification: Notification) {
        motivationText.contentInset = .zero
        keyboardToolbar.isHidden = true
        view.layoutIfNeeded()
    }
    
    func updateFromModel() {
        optionPicker.selectedSegmentIndex = model.selectedIndex
        motivationText.text = model.text
        motivationText.isEditable = model.editingEnabled
        characterCountLabel.text = model.characterCountText
        delegate?.motivationEditorDidSetText(model)
        navigationItem.leftBarButtonItem?.isEnabled = model.text.count > 10
    }
    
    func configureViews() {
        view.backgroundColor = UIColor.white
        view.addSubview(mainStack)
        mainStack.fillSuperview(padding: UIEdgeInsets(top: 8, left: 8, bottom: 44, right: 8))
        setupNavigationBar()
    }
    
    lazy var optionPicker: UISegmentedControl = {
        let view = UISegmentedControl(items: [NSLocalizedString("Default", comment: ""),NSLocalizedString("In your own words", comment: "")])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(handleOptionPickerChange), for: UIControl.Event.valueChanged)
        return view
    }()
    
    @objc func handleOptionPickerChange() {
        model.selectedIndex = optionPicker.selectedSegmentIndex
        switch model.selectedIndex {
        case 0:
            log?.track(event: .motivationTextDefaultSelected, properties: nil)
            motivationText.resignFirstResponder()
        case 1:
            log?.track(event: .motivationTextCustomSelected, properties: nil)
            motivationText.becomeFirstResponder()
        default:
            break
        }
    }
    
    @objc func handleTextChanged() {
        model.text = motivationText.text ?? ""
        characterCountLabel.text = model.characterCountText
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
        view.layer.borderColor = UIColor.darkGray.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowRadius = 16
        view.layer.shadowOpacity = 0.5
        return view
    }()
    
    lazy var keyboardToolbar: UIToolbar = {
        let bar = UIToolbar()
        let hide = UIBarButtonItem(title: "Hide", style: UIBarButtonItem.Style.plain, target: self, action: #selector(hideKeyboard))
        let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        bar.items = [space, hide]
        bar.sizeToFit()
        self.characterCountLabel.text = self.model.characterCountText
        self.characterCountLabel.frame.size = CGSize(width: 100, height: bar.frame.height)
        return bar
    }()
    
    lazy var characterCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.caption1)
        return label
    }()
    
    lazy var headingText: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Describe what motivated you to apply", comment: "")
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.title2)
        return label
    }()
    
    lazy var instructionText: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.caption1)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.text = NSLocalizedString("We advise you to describe your motivation in your own words rather than rely on the default text we we provide", comment: "")
        return label
    }()
    
    lazy var mainStack: UIStackView = {
        let views = [self.headingText,
                     self.instructionText,
                     self.optionPicker,
                     self.characterCountLabel,
                     self.motivationText]
        let stack = UIStackView(arrangedSubviews: views)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = 8
        stack.axis = .vertical
        return stack
    }()
    
    func modelDidUpdate(_ model: MotivationTextModel) {
        updateFromModel()
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
