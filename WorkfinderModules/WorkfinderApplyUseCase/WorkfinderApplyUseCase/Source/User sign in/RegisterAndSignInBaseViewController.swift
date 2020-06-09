import UIKit
import WorkfinderCommon
import WorkfinderUI
import MessageUI

class RegisterAndSignInBaseViewController: UIViewController, WorkfinderViewControllerProtocol {
    
    let presenter: RegisterAndSignInPresenterProtocol
    lazy var messageHandler = UserMessageHandler(presenter: self)
    let linkFont = UIFont.systemFont(ofSize: 14)
    let mode: RegisterAndSignInMode
    @objc var switchMode: (() -> Void)?
    @objc var onTapPrimaryButton: (() -> Void)?
    
    func updatePresenter() { fatalError("Must override") }
    func configureViews() { fatalError("Must override")}
    
    func configureNavigationBar() {
        navigationItem.title = mode.screenTitle
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backButton
        styleNavigationController()
    }
    
    init(mode: RegisterAndSignInMode, presenter: RegisterAndSignInPresenterProtocol) {
        self.mode = mode
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    @objc func hideKeyboard() { view.endEditing(true) }
    @objc func showTermsAndConditions() { openLinkInWebView(.candidateTermsAndConditions) }
    @objc func agreedTermsAndConditionsChanged(switchButton: UISwitch) { updatePresenter() }
    @objc func onPrimaryButtonTap() {
        updatePresenter()
        messageHandler.showLoadingOverlay(self.view)
        presenter.onDidTapPrimaryButton { [weak self] (optionalError) in
            guard let self = self else { return }
            self.messageHandler.hideLoadingOverlay()
            self.handleError(optionalError: optionalError)
        }
    }
        
    override func viewDidLoad() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        let safeArea = view.safeAreaLayoutGuide
        view.backgroundColor = UIColor.white
        view.addSubview(scrollView)
        view.addSubview(bottomStack)
        scrollView.anchor(top: safeArea.topAnchor, leading: safeArea.leadingAnchor, bottom: bottomStack.topAnchor, trailing: safeArea.trailingAnchor, padding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
        scrollableContentView.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant: -40).isActive = true
        bottomStack.anchor(top: nil, leading: scrollView.leadingAnchor, bottom: safeArea.bottomAnchor, trailing: scrollView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0))
        scrollableContentView.frame = scrollView.frame
        configureNavigationBar()
        configureViews()
        presenter.onViewDidLoad(self)
        refreshFromPresenter()
    }
    
    func refreshFromPresenter() {
    
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
        label.text = NSLocalizedString(mode.screenHeadingText, comment: "")
        return label
    }()
    
    lazy var email: UnderlinedNextResponderTextFieldStack = {
        let fieldName = NSLocalizedString("Email address", comment: "")
        let stack = self.makeTextStack(fieldName: fieldName)
        let textField = stack.textfield
        textField.returnKeyType = .next
        textField.keyboardType = .emailAddress
        textField.textContentType = .username
        textField.autocorrectionType = .no
        textField.placeholder = fieldName
        textField.autocapitalizationType = .none
        textField.inputAccessoryView = makeKeyboardInputAccessoryView(textField: textField)
        return stack
    }()
    
    lazy var guardianEmail: UnderlinedNextResponderTextFieldStack = {
        let fieldName = NSLocalizedString("Parent or guardian email", comment: "")
        let stack = self.makeTextStack(fieldName: fieldName)
        let textField = stack.textfield
        textField.returnKeyType = .next
        textField.keyboardType = .emailAddress
        textField.textContentType = .emailAddress
        textField.autocorrectionType = .no
        textField.placeholder = fieldName
        textField.autocapitalizationType = .none
        textField.inputAccessoryView = makeKeyboardInputAccessoryView(textField: textField)
        return stack
    }()
    
    lazy var fullname: UnderlinedNextResponderTextFieldStack = {
        let fieldName = NSLocalizedString("First and last name", comment: "")
        let stack = self.makeTextStack(fieldName: fieldName)
        let textField = stack.textfield
        textField.returnKeyType = .next
        textField.keyboardType = .alphabet
        textField.autocapitalizationType = .words
        textField.autocorrectionType = .no
        textField.textContentType = .name
        textField.placeholder = fieldName
        textField.inputAccessoryView = makeKeyboardInputAccessoryView(textField: textField)
        return stack
    }()
    
    lazy var nickname: UnderlinedNextResponderTextFieldStack = {
        let fieldName = NSLocalizedString("nickname", comment: "The user's preferred short name for themself")
        let stack = self.makeTextStack(fieldName: fieldName)
        let textField = stack.textfield
        textField.returnKeyType = .next
        textField.keyboardType = .alphabet
        textField.autocapitalizationType = .words
        textField.autocorrectionType = .no
        textField.textContentType = .nickname
        textField.placeholder = fieldName
        textField.inputAccessoryView = makeKeyboardInputAccessoryView(textField: textField)
        return stack
    }()
    
    lazy var phone: UnderlinedNextResponderTextFieldStack = {
        let fieldName = NSLocalizedString("Phone number", comment: "")
        let stack = self.makeTextStack(fieldName: fieldName)
        let textField = stack.textfield
        textField.keyboardType = .phonePad
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.textContentType = .telephoneNumber
        textField.placeholder = fieldName
        textField.inputAccessoryView = makeKeyboardInputAccessoryView(textField: textField, showNextButton: true)
        return stack
    }()
    
    lazy var password: UnderlinedNextResponderTextFieldStack = {
        let fieldName = NSLocalizedString("password", comment: "")
        let stack = self.makeTextStack(fieldName: fieldName, nextResponder: self.phone.textfield)
        if #available(iOS 12.0, *)  {
            stack.textfield.textContentType = (mode == .register) ? .newPassword : .password
        } else {
            stack.textfield.textContentType = .password
        }
        stack.textfield.autocapitalizationType = .none
        stack.textfield.autocorrectionType = .no
        stack.textfield.returnKeyType = .done
        stack.textfield.isSecureTextEntry = true
        stack.textfield.placeholder = NSLocalizedString("enter new password", comment: "prompt user to enter password")
        return stack
    }()
    
    lazy var passwordInstructionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.preferredFont(forTextStyle: .caption2)
        label.text = "Passwords must be at least 8 characters and contain a mixture of lower and upper case characters and numbers"
        label.textColor = UIColor.gray
        return label
    }()
    
    lazy var passwordStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            self.password,
            self.passwordInstructionLabel
        ])
        stack.axis = .vertical
        stack.spacing = 2
        return stack
    }()
    
    lazy var forgotPasswordStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            self.forgotPasswordLabel,
            self.forgottenPasswordButton,
            UIView()
        ])
        stack.axis = .horizontal
        stack.alignment = .firstBaseline
        stack.spacing = 4
        return stack
    }()
    
    lazy var forgotPasswordLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Forgotten password?", comment: "")
        label.font = self.linkFont
        label.textAlignment = .right
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return label
    }()
    
    lazy var forgottenPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("Reset here", comment: "reset your password here"), for: .normal)
        button.titleLabel?.font = self.linkFont
        button.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .horizontal)
        button.addTarget(self, action: #selector(forgotPassword), for: .touchUpInside)
        return button
    }()
    
    @objc func forgotPassword() {
        guard MFMailComposeViewController.canSendMail() else {
            messageHandler.displayMessage(
                title: "Email is unavailable",
                message: "Your device isn't configured for email")
            return
        }
        let composer = MFMailComposeViewController()
        composer.setToRecipients(["support@workfinder.com"])
        let email = self.email.textfield.text ?? ""
        let emailString = email.isEmpty ? "???@?????.???" : email
        composer.setPreferredSendingEmailAddress(emailString)
        composer.setMessageBody("Hi support@Workfinder.com,\n\nPlease reset the password for the user with email: \(emailString)\n\nThis email was generated from Workfinder iOS client\n", isHTML: false)
        composer.setSubject("Password reset request")
        composer.mailComposeDelegate = self
        present(composer, animated: true, completion: nil)
    }
    
    lazy var termsAgreedStack: UIStackView = {
        let textStack = UIStackView(arrangedSubviews: [
            self.termsAndConditionsLabel,
            self.termsAndConditionsButton,
            UIView()
        ])
        textStack.axis = .horizontal
        textStack.alignment = .firstBaseline
        textStack.spacing = 4
        let stack = UIStackView(arrangedSubviews: [
            self.termsAgreedSwitch, textStack, UIView()
        ])
        stack.spacing = 20
        stack.alignment = .center
        stack.axis = .horizontal
        return stack
    }()
    
    lazy var termsAndConditionsLabel: UILabel = {
        let linkLabel = UILabel()
        linkLabel.text = NSLocalizedString("I accept Workfinder's", comment: "I accept Workfinder's terms of service")
        linkLabel.font = self.linkFont
        linkLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return linkLabel
    }()
    
    lazy var termsAgreedSwitch: UISwitch = {
        let agreeSwitch = UISwitch()
        agreeSwitch.isOn = false
        agreeSwitch.thumbTintColor = WorkfinderColors.primaryColor
        agreeSwitch.addTarget(self, action: #selector(agreedTermsAndConditionsChanged), for: .valueChanged)
        return agreeSwitch
    }()
    
    lazy var termsAndConditionsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("Terms of service", comment: ""), for: .normal)
        button.titleLabel?.font = self.linkFont
        button.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .horizontal)
        button.addTarget(self, action: #selector(showTermsAndConditions), for: .touchUpInside)
        return button
    }()
    
    lazy var switchModeStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            self.switchModeLabel,
            self.switchModeButton,
            UIView()
        ])
        stack.axis = .horizontal
        stack.alignment = .firstBaseline
        stack.spacing = 4
        stack.setContentHuggingPriority(.required, for: .horizontal)
        return stack
    }()
    
    lazy var switchModeLabel: UILabel = {
        let label = UILabel()
        label.text = mode.switchModeLabelText
        label.textAlignment = .right
        label.font = self.linkFont
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        label.textAlignment = .right
        return label
    }()
    
    lazy var switchModeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(mode.switchModeActionText, for: .normal)
        button.titleLabel?.font = self.linkFont
        button.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .horizontal)
        button.addTarget(self, action: #selector(onDidTapSwitchMode), for: .touchUpInside)
        return button
    }()
    
    @objc func onDidTapSwitchMode() { presenter.onDidTapSwitchMode() }
    
    lazy var fieldStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [])
        stack.axis = .vertical
        stack.spacing = 12
        return stack
    }()
    
    lazy var bottomStack: UIStackView = {
        let bottomStack = UIStackView(arrangedSubviews: [])
        bottomStack.axis = .vertical
        bottomStack.spacing = 20
        return bottomStack
    }()
    
    lazy var primaryButton: WorkfinderPrimaryButton = {
        let button = WorkfinderPrimaryButton()
        button.addTarget(self, action: #selector(onPrimaryButtonTap), for: .touchUpInside)
        let registerTitle = self.mode.primaryActionButtonText
        button.setTitle(registerTitle, for: .normal)
        button.setTitle(registerTitle, for: .disabled)
        button.isEnabled = false
        return button
    }()
    
    lazy var scrollableContentView: UIView = {
        let view = UIView()
        view.addSubview(self.questionMarkImage)
        view.addSubview(self.titleLabel)
        view.addSubview(self.fieldStack)
        self.questionMarkImage.anchor(top: view.topAnchor, leading: nil, bottom: nil, trailing: nil, padding: UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0))
        questionMarkImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        self.titleLabel.anchor(top: questionMarkImage.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 40, left: 0, bottom: 0, right: 0))
        fieldStack.anchor(top: titleLabel.bottomAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0), size: CGSize.zero)
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
    
    func makeTextStack(fieldName: String,
                      nextResponder: UIResponder? = nil) -> UnderlinedNextResponderTextFieldStack {
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
    
    func makeKeyboardInputAccessoryView(
        textField: NextResponderTextField,
        showNextButton: Bool = false) -> UIView {
        return NextHideToolbar(textField: textField, showNextButton: showNextButton)
    }
    
    override func viewDidLayoutSubviews() {
        scrollView.contentSize = scrollableContentView.frame.size
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            scrollView.contentInset = .zero
        } else {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        scrollView.scrollIndicatorInsets = scrollView.contentInset
        updatePresenter()
    }
    
    deinit { NotificationCenter.default.removeObserver(self) }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

extension RegisterAndSignInBaseViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {

    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === password.textfield { textField.resignFirstResponder() }
        return true
    }
}

extension RegisterAndSignInBaseViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: { [weak self] in
            guard let self = self else { return }
            let messageHandler = self.messageHandler
            switch result {
            case .sent:
                messageHandler.displayMessage(title: "Sent", message: "Your password reset request has been sent")
            case .failed:
                messageHandler.displayMessage(title: "Failed", message: "Unable to send password reset email")
            case .cancelled:
                break
            case .saved:
                messageHandler.displayMessage(title: "Saved", message: "Your password reset request email has been saved in to drafts")
            @unknown default:
                break
            }
        })
    }
}

extension RegisterAndSignInBaseViewController {
    
    func handleError(optionalError: Error?) {
        let attempting  = "register/sign-in"
        func handleCentrally(_ error: Error?, allowRetry: Bool) {
            self.messageHandler.displayOptionalErrorIfNotNil(
                error,
                retryHandler: allowRetry ? self.onPrimaryButtonTap : nil)
        }

        guard var workfinderError = (optionalError as? WorkfinderError), workfinderError.code == 400 else {
            handleCentrally(optionalError, allowRetry: true)
            return
        }

        guard let data = workfinderError.responseData else {
            handleCentrally(workfinderError, allowRetry: true)
            return
        }
        
        do {
            let serverErrors = try JSONDecoder().decode(HTTPErrorJson.self, from: data)
            serverErrors.forEach { (error) in
                guard let firstErrorDescription = error.value.first else {
                    handleCentrally(workfinderError, allowRetry: true)
                    return
                }
                switch error.key {
                case "non_field_errors":
                    switch firstErrorDescription {
                    case "Unable to log in with provided credentials.":
                        workfinderError = WorkfinderError(
                            errorType: .custom(
                                title: "Unable to log in",
                                description: "Please check your email and password"),
                            attempting: attempting)
                    default:
                        workfinderError = WorkfinderError(
                            errorType: .custom(
                                title: "Unable to sign you in",
                                description: firstErrorDescription),
                            attempting: attempting)
                    }
                case "email":
                    switch firstErrorDescription {
                    case "A user is already registered with this e-mail address.":
                        workfinderError = WorkfinderError(
                            errorType: .custom(
                                title: "We already have an account with your email address",
                                description: "You cannot register with this email address. Please sign-in instead"),
                            attempting: attempting)
                    default:
                        workfinderError = WorkfinderError(
                            errorType: .custom(
                                title: "Please check your email",
                                description: "Are you sure your email address is correct?"),
                            attempting: attempting)
                    }
                default:
                    workfinderError = WorkfinderError(
                        errorType: .custom(
                            title: error.key,
                            description: firstErrorDescription),
                        attempting: attempting)
                }
                handleCentrally(workfinderError, allowRetry: false)
                
            }
        } catch {
            handleCentrally(workfinderError, allowRetry: true)
        }
    }

}
