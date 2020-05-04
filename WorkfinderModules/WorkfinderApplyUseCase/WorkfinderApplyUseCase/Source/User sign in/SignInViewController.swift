
import UIKit
import WorkfinderCommon
import WorkfinderUI

class SignInViewController: RegisterAndSignInBaseViewController {
    
    init(presenter: RegisterAndSignInPresenterProtocol) {
        super.init(mode: .signIn, presenter: presenter)
        title = mode.screenTitle
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func configureViews() {
        fieldStack.addArrangedSubview(email)
        fieldStack.addArrangedSubview(passwordStack)
        email.textChanged?(self.presenter.email)
        password.textChanged?(self.presenter.password)
        email.textfield.nextResponderField = password
        bottomStack.addArrangedSubview(forgotPasswordStack)
        bottomStack.addArrangedSubview(switchModeStack)
        bottomStack.addArrangedSubview(primaryButton)
    }
    
    override func updatePresenter()  {
        presenter.email = email.textfield.text
        presenter.password = password.textfield.text
        primaryButton.isEnabled = presenter.isPrimaryButtonEnabled
        email.state = presenter.emailValidityState
        password.state = presenter.passwordValidityState
    }
}

