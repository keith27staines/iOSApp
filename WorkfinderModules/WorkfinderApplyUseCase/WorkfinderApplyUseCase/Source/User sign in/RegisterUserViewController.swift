
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
        let showGuardianEmail = presenter.isGuardianEmailRequired
        if showGuardianEmail {
            fieldStack.addArrangedSubview(guardianEmail)
        }
        fieldStack.addArrangedSubview(fullname)
        fieldStack.addArrangedSubview(phone)
        fieldStack.addArrangedSubview(passwordStack)
        email.textChanged?(self.presenter.email)
        guardianEmail.textChanged?(self.presenter.guardianEmail)
        fullname.textChanged?(self.presenter.fullname)
        phone.textChanged?(self.presenter.phone)
        password.textChanged?(self.presenter.password)
        if showGuardianEmail {
            email.textfield.nextResponderField = guardianEmail.textfield
            guardianEmail.textfield = fullname.textfield
        } else {
            email.textfield.nextResponderField = fullname.textfield
        }
        fullname.textfield.nextResponderField = phone.textfield
        phone.textfield.nextResponderField = password.textfield
        password.textfield.nextResponderField = nil
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
            self.messageHandler.displayOptionalErrorIfNotNil(
                error,
                cancelHandler: nil,
                retryHandler: self.register)
        }
    }
    
    override func updatePresenter()  {
        presenter.fullname = fullname.textfield.text
        presenter.nickname = nickname.textfield.text
        presenter.email = email.textfield.text
        presenter.guardianEmail = guardianEmail.textfield.text
        presenter.password = password.textfield.text
        presenter.phone = phone.textfield.text
        presenter.isTermsAndConditionsAgreed = termsAgreedSwitch.isOn
        primaryButton.isEnabled = presenter.isPrimaryButtonEnabled
        email.state = presenter.emailValidityState
        guardianEmail.state = presenter.guardianValidityState
        fullname.state = presenter.fullnameValidityState
        password.state = presenter.passwordValidityState
        phone.state = presenter.phoneValidityState
        presenter.nickname = String(presenter.fullname?.split(separator: " ").first ?? "")
    }
}

