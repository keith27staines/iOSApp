
import UIKit
import WorkfinderCommon
import WorkfinderUI

class SignInViewController: RegisterAndSignInBaseViewController {
    
    init(presenter: RegisterAndSignInPresenterProtocol, hidesBackButton: Bool) {
        super.init(mode: .signIn, presenter: presenter, hidesBackButton: hidesBackButton)
        title = mode.screenTitle
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func configureViews() {
        super.configureViews()
        fieldStack.addArrangedSubview(email)
        fieldStack.addArrangedSubview(passwordStack)
        email.textChanged?(self.presenter.email)
        password1Stack.textChanged?(self.presenter.password)
        password1Stack.textfield.placeholder = "enter password"
        bottomStack.addArrangedSubview(forgotPasswordStack)
        bottomStack.addArrangedSubview(primaryButton)
        password2Stack.isHidden = true
        password2InstructionLabel.isHidden = true
    }
    
    override func updatePresenter()  {
        presenter.email = trim(email.textfield.text)
        presenter.password = trim(password1Stack.textfield.text)
        primaryButton.isEnabled = presenter.isPrimaryButtonEnabled
        email.state = presenter.emailValidityState
    }
    
    private func trim(_ string:  String?) -> String? {
        guard let string = string else { return nil }
        return string.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

