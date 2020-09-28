
import UIKit
import WorkfinderCommon
import WorkfinderUI

class RegisterUserViewController: RegisterAndSignInBaseViewController {
    
    let hidesBackButton: Bool
    
    init(presenter: RegisterAndSignInPresenterProtocol, hidesBackButton: Bool) {
        self.hidesBackButton = hidesBackButton
        super.init(mode: .register, presenter: presenter)
        title = mode.screenTitle
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesBackButton = hidesBackButton
    }
    
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
            guardianEmail.textfield.nextResponderField = fullname.textfield
        } else {
            email.textfield.nextResponderField = fullname.textfield
        }
        fullname.textfield.nextResponderField = phone.textfield
        phone.textfield.nextResponderField = password.textfield
        password.textfield.nextResponderField = nil
        bottomStack.addArrangedSubview(switchesStack)
        bottomStack.addArrangedSubview(primaryButton)
        //if hidesBackButton {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelWorkflow))
        //}
    }
    
    @objc func cancelWorkflow() {
        presenter.cancelWorkflow()
    }
    
    @objc func register() {
        updatePresenter()
        messageHandler.showLoadingOverlay(self.view)
        presenter.onDidTapPrimaryButton { [weak self] (error) in
            guard let self = self else { return }
            self.messageHandler.hideLoadingOverlay()
            self.messageHandler.displayOptionalErrorIfNotNil(
                error,
                retryHandler: self.register)
        }
    }
    
    override func updatePresenter()  {
        presenter.fullname = trim(fullname.textfield.text)
        presenter.nickname = trim(nickname.textfield.text)
        presenter.email = trim(email.textfield.text)
        presenter.guardianEmail = trim(guardianEmail.textfield.text)
        presenter.allowedSharingWithEducationInstitution = shareWithEducationalInstitutionSwitch.isOn
        presenter.allowedSharingWithEmployers = shareWithEmployersSwitch.isOn
        presenter.password = trim(password.textfield.text)
        presenter.phone = trim(phone.textfield.text)
        presenter.isTermsAndConditionsAgreed = termsAgreedSwitch.isOn
        primaryButton.isEnabled = presenter.isPrimaryButtonEnabled
        email.state = presenter.emailValidityState
        guardianEmail.state = presenter.guardianValidityState
        fullname.state = presenter.fullnameValidityState
        password.state = presenter.passwordValidityState
        phone.state = presenter.phoneValidityState
        presenter.nickname = String(presenter.fullname?.split(separator: " ").first ?? "")
    }
    
    private func trim(_ string:  String?) -> String? {
        guard let string = string else { return nil }
        return string.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

