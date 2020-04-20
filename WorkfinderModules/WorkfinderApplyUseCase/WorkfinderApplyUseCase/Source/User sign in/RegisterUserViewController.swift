
import UIKit
import WorkfinderUI

class RegisterUserViewController: UIViewController {
    let presenter: RegisterUserPresenterProtocol
    let messageHandler = UserMessageHandler()
    let linkFont = UIFont.systemFont(ofSize: 13)
    var inputControlBottom: CGFloat = 0.0
    var keyboardTop: CGFloat = 0.0 { didSet { scrollForKeyboardForInputY() } }
    
    init(presenter: RegisterUserPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
        title = "Register"
    }
    
    lazy var questionMarkImage: UIImageView = {
        let image = UIImage(named: "questionMark")?.scaledImage(with: CGSize(width: 81, height: 81))
        let imageView = UIImageView(image: image)
        imageView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        imageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.text = NSLocalizedString("Please complete the following:", comment: "")
        return label
    }()
    
    lazy var email: UnderlinedNextResponderTextFieldStack = {
        let fieldName = "Email address"
        let stack = self.makeTextView(fieldName: fieldName, nextResponder: self.fullname.textfield)
        stack.textfield.returnKeyType = .next
        stack.textfield.keyboardType = .emailAddress
        stack.textfield.textContentType = .username
        stack.textfield.placeholder = "Email address"
        stack.textfield.autocapitalizationType = .none
        stack.textfield.inputAccessoryView = makeKeyboardInputAccessoryView()
        return stack
    }()
    
    lazy var fullname: UnderlinedNextResponderTextFieldStack = {
        let fieldName = "First and last name"
        let stack = self.makeTextView(fieldName: fieldName, nextResponder: self.password.textfield)
        stack.textfield.returnKeyType = .next
        stack.textfield.keyboardType = .alphabet
        stack.textfield.autocapitalizationType = .words
        stack.textfield.placeholder = "First and last name"
        stack.textfield.inputAccessoryView = makeKeyboardInputAccessoryView()
        return stack
    }()
    
    lazy var nickname: UnderlinedNextResponderTextFieldStack = {
        let fieldName = "nickname"
        let stack = self.makeTextView(fieldName: fieldName, nextResponder: self.email.textfield)
        stack.textfield.returnKeyType = .next
        stack.textfield.keyboardType = .alphabet
        stack.textfield.autocapitalizationType = .words
        stack.textfield.textContentType = .nickname
        stack.textfield.placeholder = "nickname"
        stack.textfield.inputAccessoryView = makeKeyboardInputAccessoryView()
        return stack
    }()
    
    lazy var phone: UnderlinedNextResponderTextFieldStack = {
        let fieldName = "Phone number"
        let stack = self.makeTextView(fieldName: fieldName, nextResponder: self.registerButton)
        stack.textfield.returnKeyType = .next
        stack.textfield.keyboardType = .phonePad
        stack.textfield.autocapitalizationType = .none
        stack.textfield.textContentType = .telephoneNumber
        stack.textfield.placeholder = "Phone number"
        stack.textfield.inputAccessoryView = makeKeyboardInputAccessoryView()
        return stack
    }()
    
    lazy var password: UnderlinedNextResponderTextFieldStack = {
        let fieldName = "password"
        let stack = self.makeTextView(fieldName: fieldName, nextResponder: self.phone.textfield)
        if #available(iOS 12.0, *) {
            stack.textfield.textContentType = .newPassword
        } else {
            stack.textfield.textContentType = .password
        }
        stack.textfield.autocapitalizationType = .none
        stack.textfield.returnKeyType = .next
        stack.textfield.isSecureTextEntry = true
        stack.textfield.placeholder = "enter new password"
        return stack
    }()
    
    lazy var fieldStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            self.email,
            self.fullname,
            self.password,
            self.phone
        ])
        self.email.textChanged?(self.presenter.email)
        self.fullname.textChanged?(self.presenter.fullname)
        self.password.textChanged?(self.presenter.password)
        self.phone.textChanged?(self.presenter.phone)
        stack.axis = .vertical
        stack.spacing = 12
        return stack
    }()
    
    lazy var bottomStack: UIStackView = {
        let bottomStack = UIStackView(arrangedSubviews: [
            self.termsAgreedStack, self.registerButton])
        bottomStack.axis = .vertical
        bottomStack.spacing = 20
        return bottomStack
    }()
    
    lazy var fieldAndButtonStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            self.fieldStack,
        ])
        stack.axis = .vertical
        stack.spacing = 20
        return stack
    }()
    
    lazy var scrollableContentView: UIView = {
        let view = UIView()
        view.addSubview(self.questionMarkImage)
        view.addSubview(self.titleLabel)
        view.addSubview(self.fieldAndButtonStack)
        self.questionMarkImage.anchor(top: view.topAnchor, leading: nil, bottom: nil, trailing: nil, padding: UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0))
        questionMarkImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        self.titleLabel.anchor(top: questionMarkImage.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 40, left: 0, bottom: 0, right: 0))
        fieldAndButtonStack.anchor(top: titleLabel.bottomAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0), size: CGSize.zero)
        return view
    }()
    
    lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        let content = self.scrollableContentView
        content.frame = view.bounds
        view.addSubview(content)
        content.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var linkLabel: UILabel = {
        let linkLabel = UILabel()
        linkLabel.text = NSLocalizedString("I accept Workfinder's", comment: "start of 'I accept Workfinder's terms of service'")
        linkLabel.font = self.linkFont
        linkLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return linkLabel
    }()
    
    lazy var linkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("Terms of service", comment: ""), for: .normal)
        button.titleLabel?.font = self.linkFont
        button.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .horizontal)
        button.addTarget(self, action: #selector(showTermsAndConditions), for: .touchUpInside)
        return button
    }()
    
    func makeKeyboardInputAccessoryView() -> UIView {
        let view = UIToolbar()
        view.barStyle = UIBarStyle.default
        view.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Hide keyboard", style: UIBarButtonItem.Style.plain, target: self, action: #selector(hideKeyboard))]
        view.sizeToFit()
        return view
    }
    
    @objc func hideKeyboard() { view.endEditing(true) }
    
    @objc func showTermsAndConditions() { openLinkInWebView(.candidateTermsAndConditions) }
    
    lazy var agreeSwitch: UISwitch = {
        let agreeSwitch = UISwitch()
        agreeSwitch.isOn = false
        agreeSwitch.thumbTintColor = WorkfinderColors.primaryGreen
        agreeSwitch.addTarget(self, action: #selector(agreedTermsAndConditionsChanged), for: .valueChanged)
        return agreeSwitch
    }()
    
    @objc func agreedTermsAndConditionsChanged(switchButton: UISwitch) {
        updatePresenter()
    }
    
    lazy var termsAgreedStack: UIStackView = {
        let textStack = UIStackView(arrangedSubviews: [
            self.linkLabel, self.linkButton
        ])
        textStack.axis = .horizontal
        textStack.alignment = .firstBaseline
        textStack.spacing = 4
        let stack = UIStackView(arrangedSubviews: [
            self.agreeSwitch, textStack, UIView()
        ])
        stack.spacing = 20
        stack.alignment = .center
        stack.axis = .horizontal
        return stack
    }()
    
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self,
            selector: #selector(self.keyboardNotification(notification:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil)
        let safeArea = view.safeAreaLayoutGuide
        view.backgroundColor = UIColor.white
        view.addSubview(scrollView)
        view.addSubview(bottomStack)
        scrollView.anchor(top: safeArea.topAnchor, leading: safeArea.leadingAnchor, bottom: bottomStack.topAnchor, trailing: safeArea.trailingAnchor, padding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
        scrollableContentView.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant: -40).isActive = true
        bottomStack.anchor(top: nil, leading: scrollView.leadingAnchor, bottom: safeArea.bottomAnchor, trailing: scrollView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0))
        scrollableContentView.frame = scrollView.frame
        presenter.onViewDidLoad(self)
        email.textfield.becomeFirstResponder()
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? CGRect.zero
        keyboardTop = endFrame.origin.y
    }
    
    func scrollForKeyboardForInputY() {
        let overlap = (inputControlBottom + 40) - keyboardTop
        let scrollAmount: CGFloat = (overlap > 0) ? overlap : 0
        scrollView.setContentOffset(CGPoint(x: 0, y: scrollAmount), animated: true)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    deinit { NotificationCenter.default.removeObserver(self) }
    
    lazy var registerButton: WorkfinderPrimaryButton = {
        let button = WorkfinderPrimaryButton()
        button.addTarget(self, action: #selector(onTapRegister), for: .touchUpInside)
        let registerTitle = NSLocalizedString("Complete application", comment: "")
        button.setTitle(registerTitle, for: .normal)
        button.setTitle(registerTitle, for: .disabled)
        button.isEnabled = false
        return button
    }()
    
    lazy var alreadyHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Already have an account?", for: .normal)
        button.addTarget(self, action: #selector(onTapAlreadyHaveAccount), for: .touchUpInside)
        return button
    }()
    
    @objc func onTapRegister() {
        messageHandler.showLoadingOverlay(self.view)
        presenter.onDidTapRegister { [weak self] (error) in
            guard let self = self else { return }
            self.messageHandler.hideLoadingOverlay()
            self.messageHandler.displayAlertFor(error.localizedDescription, parentCtrl: self)
        }
    }
    
    @objc func onTapAlreadyHaveAccount() {
        presenter.onDidTapAlreadyHaveAccount()
    }
    
    func makeTextView(fieldName: String,
                      nextResponder: UIResponder?) -> UnderlinedNextResponderTextFieldStack {
        let field =  UnderlinedNextResponderTextFieldStack(
            fieldName: fieldName,
            goodUnderlineColor: UIColor.green,
            badUnderlineColor: UIColor.orange,
            state: .empty,
            nextResponderField: nextResponder)
        field.textChanged = { string in self.updatePresenter() }
        field.textfield.heightAnchor.constraint(equalToConstant: 42).isActive = true
        field.textfield.font = UIFont.systemFont(ofSize: 17)
        field.textfield.borderStyle = .none
        field.textfield.delegate = self
        return field
    }
    
    func updatePresenter()  {
        presenter.fullname = fullname.textfield.text
        presenter.nickname = nickname.textfield.text
        presenter.email = email.textfield.text
        presenter.password = password.textfield.text
        presenter.phone = phone.textfield.text
        presenter.isTermsAndConditionsAgreed = agreeSwitch.isOn
        registerButton.isEnabled = presenter.isRegisterButtonEnabled
        email.state = presenter.emailValidityState
        fullname.state = presenter.fullnameValidityState
        password.state = presenter.passwordValidityState
        phone.state = presenter.phoneValidityState
    }
}

extension RegisterUserViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let point = CGPoint(x: 0, y: textField.frame.maxY)
        inputControlBottom = textField.convert(point, to: nil).y
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        inputControlBottom = 0
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldString = textField.text, let swtRange = Range(range, in: textFieldString) else {
            
            return true
        }
        let fullString = textFieldString.replacingCharacters(in: swtRange, with: string)
        return true
    }
}

