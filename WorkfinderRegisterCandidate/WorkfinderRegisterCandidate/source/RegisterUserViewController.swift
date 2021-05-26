
import UIKit
import WorkfinderCommon
import WorkfinderUI

class RegisterUserViewController: RegisterAndSignInBaseViewController {
    
    init(presenter: RegisterAndSignInPresenterProtocol, hidesBackButton: Bool) {
        super.init(mode: .register, presenter: presenter, hidesBackButton: hidesBackButton)
        title = mode.screenTitle
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.hidesBackButton = hidesBackButton
    }
    
    override func configureViews() {
        super.configureViews()
        fieldStack.addArrangedSubview(email)
        let showGuardianEmail = presenter.isGuardianEmailRequired
        if showGuardianEmail {
            fieldStack.addArrangedSubview(guardianEmail)
        }
        fieldStack.addArrangedSubview(firstname)
        fieldStack.addArrangedSubview(lastname)
        fieldStack.addArrangedSubview(phone)
        fieldStack.addArrangedSubview(passwordStack)
        email.textChanged?(self.presenter.email)
        guardianEmail.textChanged?(self.presenter.guardianEmail)
        firstname.textChanged?(self.presenter.firstname)
        lastname.textChanged?(self.presenter.lastname)
        phone.textChanged?(self.presenter.phone)
        password.textChanged?(self.presenter.password)
        if showGuardianEmail {
            email.textfield.nextResponderField = guardianEmail.textfield
            guardianEmail.textfield.nextResponderField = firstname.textfield
        } else {
            email.textfield.nextResponderField = firstname.textfield
        }
        firstname.textfield.nextResponderField = firstname.textfield
        lastname.textfield.nextResponderField = phone.textfield
        phone.textfield.nextResponderField = password.textfield
        password.textfield.nextResponderField = nil
        bottomStack.addArrangedSubview(switchesStack)
        bottomStack.addArrangedSubview(primaryButton)
    }
    
    @objc func register() {
        updatePresenter()
        messageHandler.showLoadingOverlay(self.view)
        presenter.onDidTapPrimaryButton(from: self) { [weak self] (error) in
            guard let self = self else { return }
            self.messageHandler.hideLoadingOverlay()
            self.messageHandler.displayOptionalErrorIfNotNil(
                error,
                retryHandler: self.register)
        }
    }
    
    override func updatePresenter()  {
        presenter.firstname = trim(firstname.textfield.text)
        presenter.lastname = trim(lastname.textfield.text)
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
        firstname.state = presenter.firstnameValidityState
        lastname.state = presenter.lastnameValidityState
        password.state = presenter.passwordValidityState
        phone.state = presenter.phoneValidityState
    }
    
    private func trim(_ string:  String?) -> String? {
        guard let string = string else { return nil }
        return string.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

