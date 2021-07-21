
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
    
    //override var confirmPasswordTextField: UnderlinedNextResponderTextFieldStack
    
    override func configureViews() {
        super.configureViews()
        fieldStack.addArrangedSubview(email)
//        fieldStack.addArrangedSubview(firstname)
//        fieldStack.addArrangedSubview(lastname)
        fieldStack.addArrangedSubview(passwordStack)
        email.textChanged?(self.presenter.email)
//        firstname.textChanged?(self.presenter.firstname)
//        lastname.textChanged?(self.presenter.lastname)
        password1Stack.textChanged?(self.presenter.password)
//        email.textfield.nextResponderField = firstname.textfield
//        firstname.textfield.nextResponderField = lastname.textfield
        //lastname.textfield.nextResponderField = password1Stack.textfield
        bottomStack.addArrangedSubview(switchesStack)
        bottomStack.addArrangedSubview(primaryButton)
        password2Stack.isHidden = false
        password2InstructionLabel.isHidden = false
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
//        presenter.firstname = trim(firstname.textfield.text)
//        presenter.lastname = trim(lastname.textfield.text)
        presenter.email = trim(email.textfield.text)
        presenter.password = trim(password1Stack.textfield.text)
        presenter.password2 = trim(password2Stack.textfield.text)
        presenter.isTermsAndConditionsAgreed = termsAgreedSwitch.isOn
        primaryButton.isEnabled = presenter.isPrimaryButtonEnabled
        email.state = presenter.emailValidityState
//        firstname.state = presenter.firstnameValidityState
//        lastname.state = presenter.lastnameValidityState
        password1Stack.state = presenter.passwordValidityState
        password2Stack.state = presenter.password2ValidityState
    }
    
    private func trim(_ string:  String?) -> String? {
        guard let string = string else { return nil }
        return string.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

