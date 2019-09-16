import UIKit
import WorkfinderCommon
import WorkfinderNetworking
import WorkfinderServices
import WorkfinderUI

class UserDetailsViewController: UIViewController {
    
    var viewModel: UserDetailsViewModel!
    weak var coordinator: UserDetailsCoordinator!
    
    @IBOutlet weak var exploreMapButton: UIButton!
    @IBOutlet weak var tooYoungStackView: UIStackView!
    @IBOutlet weak var acceptConditionsStackView: UIStackView!
    @IBOutlet weak var consentGiventSwitch: UISwitch!
    @IBOutlet weak var consentGivenLinkButton: UIButton!
    @IBOutlet weak var infoStackViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var completionImageView: UIImageView!
    @IBOutlet weak var userInfoStackView: UIStackView!
    @IBOutlet weak var dobTextField: UITextField!
    
    @IBOutlet weak var dobInfoLabel: UILabel!
    @IBOutlet weak var parentEmailInfoLabel: UILabel!
    @IBOutlet weak var userEmailInfoLabel: UILabel!
    @IBOutlet weak var namesInfoLabel: UILabel!
    
    @IBOutlet weak var dobUnderlineView: UIView!
    @IBOutlet weak var completeExtraInfoButton: UIButton!
    @IBOutlet weak var parentEmailStackView: UIStackView!
    @IBOutlet weak var parentEmailTextField: NextResponderTextField!
    @IBOutlet weak var parentEmailUnderlineView: UIView!
    @IBOutlet weak var emailStackView: UIStackView!
    @IBOutlet weak var emailTextField: NextResponderTextField!
    @IBOutlet weak var emailUnderlineView: UIView!
    @IBOutlet weak var firstAndLastNameStackView: UIStackView!
    @IBOutlet weak var firstAndLastNameTextField: NextResponderTextField!
    @IBOutlet weak var firstAndLastNameUnderlineView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    var datePicker = UIDatePicker()
    var userRepository: F4SUserRepositoryProtocol!
    var userService: F4SUserServiceProtocol!
    var emailVerificationService: EmailVerificationServiceProtocol!
    
    func inject(
        viewModel: UserDetailsViewModel,
        userRepository: F4SUserRepositoryProtocol,
        userService: F4SUserServiceProtocol,
        emailVerificationService: EmailVerificationServiceProtocol) {
        self.viewModel = viewModel
        self.userRepository  = userRepository
        self.userService = userService
    }
    
    lazy var emailController: F4SEmailVerificationViewController = {
        let emailStoryboard = UIStoryboard(name: "F4SEmailVerification", bundle: __bundle)
        let emailController = emailStoryboard.instantiateViewController(withIdentifier: "EmailVerification") as! F4SEmailVerificationViewController
        emailController.emailVerificationService = self.emailVerificationService
        return emailController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.viewController = self
        setupControls()
        datePicker.date = viewModel.dateOfBirth ?? viewModel.defaultDateOfBirth
        configureForExistingUserInfo()
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyStyle()
        adjustNavigationBar()
        updateVisualState()
    }
    
    func applyStyle() {
        let skinner = Skinner()
        skinner.apply(buttonSkin: skin?.primaryButtonSkin, to: exploreMapButton)
        skinner.apply(buttonSkin: skin?.primaryButtonSkin, to: completeExtraInfoButton)
    }
    
    @IBAction func termsOfServiceLinkButton(_ sender: UIButton) {
        coordinator?.presentContent(F4SContentType.terms)
    }
    
    @IBAction func exploreMoreCompanies(_ sender: Any) {
        viewModel.exploreMoreCompanies()
    }
    @IBAction func termsAgreedChanged(_ sender: UISwitch) {
        viewModel.userInfo.termsAgreed = sender.isOn
        updateVisualState()
    }
    
    @IBAction func emailTextFieldDidChange(_ sender: NextResponderTextField) {
        viewModel.userInfo.email = sender.text
        updateVisualState()
    }
    
    @IBAction func parentEmailTextFieldDidChange(_ sender: NextResponderTextField) {
        viewModel.userInfo.parentEmail = sender.text
        updateVisualState()
    }
    
    @IBAction func firstNameAndLastNameTextFieldDidChange(_ sender: NextResponderTextField) {
        viewModel.setNames(sender.text)
        updateVisualState()
    }
    
    var pushNotificationAlertFactory = RequestPushNotificationsAlertFactory()
    
    @IBAction func completeInfoButtonTouched(_: UIButton) {
        self.view.endEditing(true)
        saveUserDetailsLocally()
        pushNotificationAlertFactory.afterAction = {
            [weak self] in self?.verifyEmail()
        }
        pushNotificationAlertFactory.makeAlertViewControllerIfNecessary { [weak self] (controller) in
            DispatchQueue.main.async {
                guard let controller = controller else {
                    self?.verifyEmail()
                    return
                }
                self?.present(controller, animated: true, completion: nil)
            }
        }
    }
    
    deinit { NotificationCenter.default.removeObserver(self) }
}

// MARK: - Handle keyboard
extension UserDetailsViewController {
    
    /// Handles changes to keyboard size and position
    @objc func keyboardNotification(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        let duration:TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
        let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
        let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
        let animationCurve:UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
        if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
            let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            scrollView.contentInset = contentInset
            scrollView.scrollIndicatorInsets = contentInset
        } else {
            if let keyboardSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height + 20, right: 0)
                scrollView.contentInset = contentInsets
                scrollView.scrollIndicatorInsets = contentInsets
            }
        }
        UIView.animate(withDuration: duration,
                       delay: TimeInterval(0),
                       options: animationCurve,
                       animations: { self.view.layoutIfNeeded() },
                       completion: nil)
        
    }
}

// MARK: - UI Setup
extension UserDetailsViewController {
    
    func setupControls() {
        setupDatePicker()
        setupTextFields()
        setupLabels()
        self.userInfoStackView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setupTextFields() {
        dobTextField.placeholder = viewModel.dateOfBirthPlaceholder
        firstAndLastNameTextField.placeholder = viewModel.namePlaceholder
        dobTextField.inputView = datePicker
    }
    
    func setupLabels() {
        dobInfoLabel.attributedText = viewModel.dateOfBirthInformationString
        parentEmailInfoLabel.attributedText = viewModel.parentEmailInformationString
        userEmailInfoLabel.attributedText = viewModel.userEMailInformationString
        namesInfoLabel.attributedText = viewModel.namesInformationString
        dobInfoLabel.isUserInteractionEnabled = true
        let dobInfoLabelTap = UITapGestureRecognizer(target: self, action: #selector(didTapDobInfoLabel))
        dobInfoLabelTap.numberOfTapsRequired = 1
        dobInfoLabel.addGestureRecognizer(dobInfoLabelTap)
    }
    
    func setupDatePicker() {
        let toolBar = UIToolbar()
        let vm = viewModel.dateOfBirthViewModel
        vm.configureDatePickerAppearance(datePicker)
        vm.configureToolbarAppearance(toolBar)
        toolBar.tintColor = skin?.primaryButtonSkin.backgroundColor.uiColor
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(datePickerDoneButtonTouched))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(datePickerCancelButtonTouched))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        dobTextField.inputAccessoryView = toolBar
    }
    
    func adjustNavigationBar() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.navigationBar.barTintColor = UIColor(netHex: Colors.black)
        navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.isTranslucent = false
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    func configureForExistingUserInfo() {
        if viewModel.dateOfBirth == nil {
            let screenHeight = self.view.bounds.height
            let infoLabelY = self.dobInfoLabel.frame.maxY
            let stackViewHeight = self.userInfoStackView.bounds.height
            infoStackViewTopConstraint.constant = screenHeight - infoLabelY - stackViewHeight + 90
            scrollView.isScrollEnabled = false
        } else {
            infoStackViewTopConstraint.constant = 49
            scrollView.isScrollEnabled = true
        }
    }
    
    func buildUserInfo() -> F4SUser {
        return viewModel.buildUser()
    }
    
    func updateVisualState() {
        updateDisplayedValues()
        tooYoungStackView.isHidden = viewModel.isUserTooYoungStackHidden
        userInfoStackView.isHidden = viewModel.isUserInfoStackHidden
        parentEmailStackView.isHidden = viewModel.isParentEmailStackHidden
        emailStackView.isHidden = viewModel.isUserEmailStackHidden
        firstAndLastNameStackView.isHidden = viewModel.isFirstAndLastNameStackHidden
        acceptConditionsStackView.isHidden = viewModel.isAgreeTermsStackHidden
        dobUnderlineView.backgroundColor = viewModel.dateOfBirthUnderlineColor
        emailUnderlineView.backgroundColor = viewModel.userEmailUnderlineColor
        parentEmailUnderlineView.backgroundColor = viewModel.parentEmailUnderlineColor
        firstAndLastNameUnderlineView.backgroundColor = viewModel.nameUnderlineColor
        completeExtraInfoButton.isEnabled = viewModel.isCompleteInformationButtonEnabled
        completionImageView.image = viewModel.image
    }
    
    func updateDisplayedValues() {
        dobTextField.text = viewModel.dateOfBirthText
        parentEmailTextField.text = viewModel.parentEmail
        emailTextField.text = viewModel.userEmail
        firstAndLastNameTextField.text = viewModel.userName
        consentGiventSwitch.isOn = viewModel.termsAgreed
    }
}

// MARK: - UITextFieldDelegate
extension UserDetailsViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_: UITextField) -> Bool {
        return true
    }
}

// MARK: - Calls
extension UserDetailsViewController {
    
    func saveUserDetailsLocally() {
        let updatedUser = self.buildUserInfo()
        userRepository?.save(user: updatedUser)
    }
}

// MARK: - User Interaction
extension UserDetailsViewController {
    
    @objc func datePickerDoneButtonTouched() {
        viewModel.dateOfBirth = datePicker.date
        dobTextField.text = viewModel.dateOfBirthText
        dobTextField.resignFirstResponder()
        scrollView.isScrollEnabled = true
        self.infoStackViewTopConstraint.constant = 49
        self.updateVisualState()
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.updateDOBValidityUnderlining()
            strongSelf.view.layoutIfNeeded()
        })
    }
    
    func updateDOBValidityUnderlining() {
        dobUnderlineView.backgroundColor = viewModel.dateOfBirthUnderlineColor
    }
    
    @objc func datePickerCancelButtonTouched() {
        dobTextField.resignFirstResponder()
    }
    
    @objc func didTapDobInfoLabel(recognizer: UITapGestureRecognizer) {
        coordinator?.presentContent(F4SContentType.consent)
    }
    
    func verifyEmail() {
        let emailController = self.emailController
        let emailModel = emailController.model
        let user = userRepository.load()
        if emailModel.isEmailAddressVerified(email: user.email) {
            afterEmailVerfied(verifiedEmail: user.email!)
        } else {
            emailController.emailToVerify = user.email
            emailController.model.restart()
            emailController.emailWasVerified = { [weak self] in
                guard let strongSelf = self else { return }
                DispatchQueue.main.async {
                    strongSelf.emailTextField.text = emailController.model.verifiedEmail
                    _ = strongSelf.saveUserDetailsLocally()
                    strongSelf.afterEmailVerfied(verifiedEmail: emailController.model.verifiedEmail!)
                }
            }
            self.navigationController!.pushViewController(emailController, animated: true)
        }
    }
    
    func afterEmailVerfied(verifiedEmail: String) {
        var user = userRepository.load()
        user.email = verifiedEmail
        userRepository.save(user: user)
        saveUserToServer()
    }
    
    func saveUserToServer() {
        showLoadingOverlay()
        var user = userRepository.load()
        userService.updateUser(user: user) { [weak self] (result) in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                //strongSelf.hideLoadingOverlay()
                switch result {
                case .error(let error):
                    if error.retry {
                        strongSelf.handleRetryForNetworkError(error, retry: {
                            strongSelf.saveUserToServer()
                        })
                    } else {
                        sharedUserMessageHandler.display(error, parentCtrl: strongSelf, cancelHandler: nil
                            , retryHandler: {
                                strongSelf.saveUserToServer()
                        })
                    }
                case .success(let userModel):
                    guard let newUuid = userModel.uuid else {
                        sharedUserMessageHandler.displayWithTitle("Something went wrong", "Workfinder cannot complete this operation", parentCtrl: strongSelf)
                        return
                    }
                    let oldUuid = user.uuid ?? "nil"
                    strongSelf.coordinator?.injected.log.debug("PATCHED user:\nold uuid: \(oldUuid)\nnew uuid: \(newUuid)", functionName: #function, fileName: #file, lineNumber: #line)
                    
                    user.uuid = newUuid
                    strongSelf.userRepository?.save(user: user)
                    strongSelf.afterUserSavedToServer()
                }
            }
        }
    }
    
    func afterUserSavedToServer() {
        didComplete()
    }
    
    func didComplete() {
        coordinator?.userDetailsDidComplete()
    }
}

extension UserDetailsViewController {
    
    func showLoadingOverlay() {
        sharedUserMessageHandler.showLoadingOverlay(self.view)
    }
    func hideLoadingOverlay() {
        sharedUserMessageHandler.hideLoadingOverlay()
    }
    
    func presentInvalidVoucherAlert(reason: String) {
        let alert = UIAlertController(
            title: NSLocalizedString("Voucher is not valid", comment: ""),
            message: reason,
            preferredStyle: .alert)
        let okAction = UIAlertAction(
            title: NSLocalizedString("OK", comment: ""),
            style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func handleRetryForNetworkError(_ error: F4SNetworkError, retry: @escaping () -> () ) {
        sharedUserMessageHandler.display(error, parentCtrl: self, cancelHandler: nil) {
            retry()
        }
    }
    
    func handleUnrecoverableError(_ error: Error) {
        sharedUserMessageHandler.hideLoadingOverlay()
        sharedUserMessageHandler.displayAlertFor(error.localizedDescription, parentCtrl: self)
    }
}

