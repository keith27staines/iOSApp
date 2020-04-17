
import UIKit
import WorkfinderUI

class RegisterUserViewController: UIViewController {
    let presenter: RegisterUserPresenterProtocol
    let messageHandler = UserMessageHandler()
    
    init(presenter: RegisterUserPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
        title = "Register"
    }
    
    lazy var fullname: UnderlinedNextResponderTextFieldStack = {
        let fieldName = "full name"
        let validator = self.presenter.fullnameValidator
        let stack = self.makeTextView(fieldName: fieldName, validator: validator, nextResponder: self.nickname.textfield)
        stack.textfield.returnKeyType = .next
        stack.textfield.keyboardType = .alphabet
        stack.textfield.autocapitalizationType = .words
        stack.textfield.placeholder = "full name"
        return stack
    }()
    
    lazy var nickname: UnderlinedNextResponderTextFieldStack = {
        let fieldName = "nickname"
        let validator = self.presenter.nicknameValidator
        let stack = self.makeTextView(fieldName: fieldName, validator: validator, nextResponder: self.email.textfield)
        stack.textfield.returnKeyType = .next
        stack.textfield.keyboardType = .alphabet
        stack.textfield.autocapitalizationType = .words
        stack.textfield.textContentType = .nickname
        stack.textfield.placeholder = "nickname"
        return stack
    }()
    
    lazy var email: UnderlinedNextResponderTextFieldStack = {
        let fieldName = "email"
        let validator = self.presenter.emailValidator
        let stack = self.makeTextView(fieldName: fieldName, validator: validator, nextResponder: self.password.textfield)
        stack.textfield.returnKeyType = .next
        stack.textfield.keyboardType = .emailAddress
        stack.textfield.textContentType = .username
        stack.textfield.placeholder = "email address"
        stack.textfield.autocapitalizationType = .none
        return stack
    }()
    
    lazy var password: UnderlinedNextResponderTextFieldStack = {
        let fieldName = "password"
        let validator = self.presenter.passwordValidator
        let stack = self.makeTextView(fieldName: fieldName, validator: validator, nextResponder: self.registerButton)
        if #available(iOS 12.0, *) {
            stack.textfield.textContentType = .newPassword
        } else {
            stack.textfield.textContentType = .password
        }
        stack.textfield.autocapitalizationType = .none
        stack.textfield.returnKeyType = .done
        stack.textfield.isSecureTextEntry = true
        stack.textfield.placeholder = "enter new password"
        return stack
    }()
    
    lazy var fieldStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            self.fullname,
            self.nickname,
            self.email,
            self.password
        ])
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }()
    
    lazy var fieldAndButtonStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            self.fieldStack,
            self.alreadyHaveAccountButton,
            self.registerButton
        ])
        stack.axis = .vertical
        stack.spacing = 20
        return stack
    }()
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor.white
        view.addSubview(fieldAndButtonStack)
        fieldAndButtonStack.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: nil, trailing: view.safeAreaLayoutGuide.trailingAnchor, padding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20), size: CGSize.zero)
        presenter.onViewDidLoad(self)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    lazy var registerButton: WorkfinderPrimaryButton = {
        let button = WorkfinderPrimaryButton()
        button.addTarget(self, action: #selector(onTapRegister), for: .touchUpInside)
        let registerTitle = NSLocalizedString("Register", comment: "")
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
                      validator: @escaping ((String) -> UnderlineView.State),
                      nextResponder: UIResponder?) -> UnderlinedNextResponderTextFieldStack {
        let field =  UnderlinedNextResponderTextFieldStack(
            fieldName: fieldName,
            goodUnderlineColor: UIColor.green,
            badUnderlineColor: UIColor.orange,
            state: .empty, validator: validator,
            nextResponderField: nextResponder)
        field.textChanged = { string in
            self.updatePresenter()
            self.registerButton.isEnabled = self.presenter.isRegisterButtonEnabled
            field.underline.state = validator(string ?? "")
        }
        field.textfield.heightAnchor.constraint(equalToConstant: 45).isActive = true
        field.textfield.borderStyle = .none
        return field
    }
    
    func updatePresenter()  {
        presenter.fullname = fullname.textfield.text
        presenter.nickname = nickname.textfield.text
        presenter.email = email.textfield.text
        presenter.password = password.textfield.text
    }
}
