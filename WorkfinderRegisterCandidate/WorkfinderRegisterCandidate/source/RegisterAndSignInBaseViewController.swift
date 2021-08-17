import UIKit
import WorkfinderCommon
import WorkfinderUI
import MessageUI

class RegisterAndSignInBaseViewController: UIViewController, WorkfinderViewControllerProtocol {
    
    let presenter: RegisterAndSignInPresenterProtocol
    lazy var messageHandler = UserMessageHandler(presenter: self)
    let linkFont = WorkfinderFonts.body2
    let mode: RegisterAndSignInMode
    let hidesBackButton: Bool
    
    @objc var switchMode: (() -> Void)?
    @objc var onTapPrimaryButton: (() -> Void)?
    
    @objc func hideKeyboard() { view.endEditing(true) }
    @objc func showTermsAndConditions() { openLinkInWebView(.candidateTermsAndConditions) }
    @objc func agreedTermsAndConditionsChanged(switch: UISwitch) { updatePresenter() }
    @objc func shareWithEmployersChanged(switch: UISwitch) { updatePresenter() }
    @objc func shareWithEducationalInstitutionChanged(switch: UISwitch) { updatePresenter() }
    @objc func onDidTapSwitchMode() { presenter.onDidTapSwitchMode() }
    @objc func onPrimaryButtonTap() {
        updatePresenter()
        view.endEditing(true)
        messageHandler.showLoadingOverlay(self.view)
        presenter.onDidTapPrimaryButton(from: self) { [weak self] (optionalError) in
            guard let self = self else { return }
            self.messageHandler.hideLoadingOverlay()
            self.handleError(optionalError: optionalError)
        }
    }
    
    func updatePresenter() { fatalError("Must override") }
    
    func configureViews() {
        if hidesBackButton {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelWorkflow))
        }
    }
    
    func configureNavigationBar() {
        navigationItem.title = mode.screenTitle
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backButton
        styleNavigationController()
    }
    
    init(mode: RegisterAndSignInMode, presenter: RegisterAndSignInPresenterProtocol, hidesBackButton: Bool) {
        self.hidesBackButton = hidesBackButton
        self.mode = mode
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    @objc func cancelWorkflow() {
        presenter.cancelWorkflow()
    }
        
    override func viewDidLoad() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        let guide = view.safeAreaLayoutGuide
        view.backgroundColor = UIColor.white
        view.addSubview(scrollView)
        scrollView.anchor(top: guide.topAnchor, leading: guide.leadingAnchor, bottom: guide.bottomAnchor, trailing: guide.trailingAnchor, padding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
        scrollableContentView.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant: -40).isActive = true
        scrollableContentView.frame = scrollView.frame
        configureNavigationBar()
        configureViews()
        presenter.onViewDidLoad(self)
        refreshFromPresenter()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        password1Stack.state = .empty
        password2Stack.state = .empty
    }
    
    func refreshFromPresenter() {
    
    }
    
    lazy var screenIcon: UIImageView = {
        let image = UIImage(named: "register")?.scaledImage(with: CGSize(width: 81, height: 81))
        let imageView = UIImageView(image: image)
        imageView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        imageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    // MARK:- Title stack
    lazy var titleStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            self.switchModeStack
        ])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .center
        return stack
    }()
    
    lazy var switchModeStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            UIView(),
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
        label.textColor = UIColor.darkText
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
        button.tintColor = WorkfinderColors.primaryColor
        button.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .horizontal)
        button.addTarget(self, action: #selector(onDidTapSwitchMode), for: .touchUpInside)
        return button
    }()
    
    // MARK:- Registration fields
    lazy var email: UnderlinedNextResponderTextFieldStack = {
        let fieldName = NSLocalizedString("Email address", comment: "")
        let stack = self.makeTextStack(fieldName: fieldName)
        let textField = stack.textfield
        textField.textColor = UIColor.darkText
        textField.returnKeyType = .next
        textField.keyboardType = .emailAddress
        textField.textContentType = .username
        textField.autocorrectionType = .no
        textField.placeholder = fieldName
        textField.autocapitalizationType = .none
        textField.inputAccessoryView = makeKeyboardInputAccessoryView(textField: textField)
        return stack
    }()
        
    lazy var password1Stack: UnderlinedNextResponderTextFieldStack = {
        let fieldName = NSLocalizedString("password", comment: "")
        let stack = self.makeTextStack(fieldName: fieldName, nextResponder: nil)
        stack.textfield.textContentType = (mode == .register) ? .password : .password
        stack.textfield.textColor = UIColor.darkText
        stack.textfield.isSecureTextEntry = true
        stack.textfield.placeholder = NSLocalizedString("Password", comment: "prompt user to enter password")
        password = stack.textfield
        return stack
    }()
    
    private var password: UITextField?
    private var confirmPassword: UITextField?
    
    lazy var password2Stack: UnderlinedNextResponderTextFieldStack = {
        let fieldName = NSLocalizedString("Confirm password", comment: "")
        let stack = self.makeTextStack(fieldName: fieldName, nextResponder: nil)
        stack.textfield.textContentType = (mode == .register) ? .password : .password
        stack.textfield.textColor = UIColor.darkText
        stack.textfield.isSecureTextEntry = true
        stack.textfield.placeholder = NSLocalizedString("Confirm password", comment: "prompt user to enter password")
        confirmPassword = stack.textfield
        return stack
    }()
    
    lazy var passwordInstructionLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.darkText
        label.numberOfLines = 0
        label.font = UIFont.preferredFont(forTextStyle: .caption2)
        label.text = "Passwords must be at least 8 characters and contain a mixture of lower and upper case characters and numbers"
        label.textColor = UIColor(red: 33, green: 33, blue: 33)
        return label
    }()

    lazy var password2InstructionLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.darkText
        label.numberOfLines = 0
        label.font = UIFont.preferredFont(forTextStyle: .caption2)
        label.text = "Passwords must match!"
        label.textColor = UIColor(red: 33, green: 33, blue: 33)
        return label
    }()

    lazy var passwordStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            self.password1Stack,
            self.passwordInstructionLabel,
            self.password2Stack,
            self.password2InstructionLabel
        ])
        stack.axis = .vertical
        stack.spacing = 8
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
        label.textColor = UIColor.darkText
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
        let button = WorkfinderControls.makePrimaryButton()
        button.addTarget(self, action: #selector(onPrimaryButtonTap), for: .touchUpInside)
        let registerTitle = self.mode.primaryActionButtonText
        button.setTitle(registerTitle, for: .normal)
        button.setTitle(registerTitle, for: .disabled)
        button.isEnabled = false
        return button
    }()
    
    lazy var scrollableContentView: UIView = {
        let view = UIView()
        view.addSubview(self.screenIcon)
        view.addSubview(self.titleStack)
        view.addSubview(self.fieldStack)
        view.addSubview(self.bottomStack)
        self.screenIcon.anchor(top: view.topAnchor, leading: nil, bottom: nil, trailing: nil, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        screenIcon.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        self.titleStack.anchor(top: screenIcon.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0))
        fieldStack.anchor(top: titleStack.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 13, left: 0, bottom: 0, right: 0), size: CGSize.zero)
        bottomStack.anchor(top: fieldStack.bottomAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 27, left: 0, bottom: 20, right: 0))
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
    
    override func viewDidLayoutSubviews() {
        scrollView.contentSize = scrollableContentView.frame.size
    }
    
    deinit { NotificationCenter.default.removeObserver(self) }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK:- switches stack
    lazy var switchesStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            self.termsAndConditionsStack,
        ])
        stack.axis = .vertical
        stack.spacing = 28
        return stack
    }()
    
    lazy var termsAndConditionsStack: UIStackView = {
        makeSwitchStack(theSwitch: termsAgreedSwitch, label: termsAndConditionsActiveLabel)
    }()
    lazy var termsAgreedSwitch: UISwitch = { makeSwitch(selector: #selector(agreedTermsAndConditionsChanged)) }()

    lazy var termsAndConditionsActiveLabel: UILabel = {
        let title = NSLocalizedString("I accept Workfinder's", comment: "I accept Workfinder's [e.g. terms of service]")
        let link = NSLocalizedString("Terms of service", comment: "")
        let selector = #selector(showTermsAndConditions)
        return makeSwitchLinkLabel(text: title, linkText: link, selector: selector)
    }()
}

extension RegisterAndSignInBaseViewController {
    
    @objc func showFindOutMoreAlert() {
        let message = "Workfinder partners with schools and universities so that they can provide additional support to their students.\n\nBy opting in, you are agreeing to your educational institution being informed about your profile, applications, recommendations and how they are progressing."
        let alert = UIAlertController(
            title: "Opt-in information",
            message: message,
            preferredStyle: .alert)
        let action = UIAlertAction(title: "Close", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func makeTextStack(fieldName: String,
                      nextResponder: UIResponder? = nil) -> UnderlinedNextResponderTextFieldStack {
        let field =  UnderlinedNextResponderTextFieldStack(
            fieldName: fieldName,
            goodUnderlineColor: WorkfinderColors.primaryColor,
            badUnderlineColor: WorkfinderColors.badValueNormal,
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
    
    func makeSwitchStack(theSwitch: UISwitch, label: UILabel) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: [
            theSwitch,
            label
        ])
        stack.spacing = 34
        stack.alignment = .center
        stack.axis = .horizontal
        return stack
    }
    
    func makeSwitch(selector: Selector) -> UISwitch {
        let control = WorkfinderControls.makeSwitch()
        control.isOn = false
        control.addTarget(self, action: selector, for: .valueChanged)
        control.setContentHuggingPriority(.required, for: .horizontal)
        return control
    }

    func makeSwitchLabel(text: String) -> UILabel {
        let label = UILabel()
        label.textColor = UIColor.darkText
        label.numberOfLines = 2
        label.attributedText = makeAttributedText(text: text, linkText: nil)
        return label
    }
    
    func makeSwitchLinkLabel(text: String, linkText: String, selector: Selector) -> UILabel {
        let label = UILabel()
        label.textColor = UIColor.darkText
        label.isUserInteractionEnabled = true
        label.numberOfLines = 2
        label.attributedText = makeAttributedText(text: text, linkText: linkText)
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: selector))
        return label
    }
    
    func makeAttributedText(text: String, linkText link: String?) -> NSAttributedString {
        let font = UIFont.systemFont(ofSize: 13)
        let string1 = NSAttributedString(string: "\(text) ", attributes: [.font : font])
        guard let link = link else { return string1 }
        let string2 = NSAttributedString(string: link, attributes: [.font : font, .foregroundColor: WorkfinderColors.primaryColor])
        let concatenated = NSMutableAttributedString(attributedString: string1)
        concatenated.append(string2)
        return concatenated
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
    
    @objc func forgotPassword() { openLinkInWebView(.resetPassword) }
}

extension RegisterAndSignInBaseViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {

    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
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
