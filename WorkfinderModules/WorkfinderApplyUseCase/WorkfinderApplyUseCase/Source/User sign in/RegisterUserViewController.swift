
import UIKit
import WorkfinderCommon
import WorkfinderUI

class RegisterUserViewController: RegisterAndSignInBaseViewController {
    
    init(presenter: RegisterAndSignInPresenterProtocol) {
        super.init(mode: .register, presenter: presenter)
        title = mode.screenTitle
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func configureViews() {
        fieldStack.addArrangedSubview(email)
        fieldStack.addArrangedSubview(fullname)
        fieldStack.addArrangedSubview(phone)
        fieldStack.addArrangedSubview(passwordStack)
        email.textChanged?(self.presenter.email)
        fullname.textChanged?(self.presenter.fullname)
        phone.textChanged?(self.presenter.phone)
        password.textChanged?(self.presenter.password)
        email.textfield.nextResponderField = fullname.textfield
        fullname.textfield.nextResponderField = phone.textfield
        phone.textfield.nextResponderField = password.textfield
        password.textfield.nextResponderField = nil //email.textfield
        bottomStack.addArrangedSubview(termsAgreedStack)
        bottomStack.addArrangedSubview(switchModeStack)
        bottomStack.addArrangedSubview(primaryButton)
    }
    
    @objc func register() {
        updatePresenter()
        messageHandler.showLoadingOverlay(self.view)
        presenter.onDidTapPrimaryButton { [weak self] (error) in
            guard let self = self else { return }
            self.messageHandler.hideLoadingOverlay()
            self.messageHandler.displayAlertFor(error.localizedDescription, parentCtrl: self)
        }
    }
    
    override func updatePresenter()  {
        presenter.fullname = fullname.textfield.text
        presenter.nickname = nickname.textfield.text
        presenter.email = email.textfield.text
        presenter.password = password.textfield.text
        presenter.phone = phone.textfield.text
        presenter.isTermsAndConditionsAgreed = termsAgreedSwitch.isOn
        primaryButton.isEnabled = presenter.isPrimaryButtonEnabled
        email.state = presenter.emailValidityState
        fullname.state = presenter.fullnameValidityState
        password.state = presenter.passwordValidityState
        phone.state = presenter.phoneValidityState
        presenter.nickname = String(presenter.fullname?.split(separator: " ").first ?? "")
    }
}

