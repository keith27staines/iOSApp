//
//  ExtraInfoViewController.swift
//  f4s-workexperience
//
//  Created by Sergiu Simon on 11/12/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import UIKit
import Reachability

class ExtraInfoViewController: UIViewController {
    
    @IBOutlet weak var exploreMapButton: UIButton!
    @IBAction func exploreMoreCompanies(_ sender: Any) {
        CustomTabBarViewController.rewindToDrawerAndSelectTab(vc: self.navigationController!, tab: .map)
    }
    @IBOutlet weak var toYoungStackView: UIStackView!
    
    let consentPreviouslyGivenKey = "consentPreviouslyGivenKey"
    
    @IBOutlet weak var acceptConditionsStackView: UIStackView!
    @IBOutlet weak var consentGiventSwitch: UISwitch!
    
    @IBOutlet weak var consentGivenLinkButton: UIButton!
    
    @IBAction func termsOfServiceLinkButton(_ sender: UIButton) {
        if let navigCtrl = self.navigationController {
            CustomNavigationHelper.sharedInstance.presentContentViewController(navCtrl: navigCtrl, contentType: F4SContentType.terms)
        }
    }
    
    @IBAction func consentGivenChanged(_ sender: UISwitch) {
        updateButtonStateAndImage()
    }
    @IBOutlet weak var infoStackViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var completionImageView: UIImageView!
    
    @IBOutlet weak var dobTextField: UITextField!
    @IBOutlet weak var dobInfoLabel: UILabel!
    @IBOutlet weak var dobUnderlineView: UIView!
    @IBOutlet weak var completeExtraInfoButton: UIButton!
    @IBOutlet weak var userInfoStackView: UIStackView!
    
    @IBOutlet weak var emailTextField: NextResponderTextField!
    @IBOutlet weak var emailUnderlineView: UIView!
    @IBOutlet weak var emailStackView: UIStackView!
    
    @IBOutlet weak var firstAndLastNameTextField: NextResponderTextField!
    @IBOutlet weak var firstAndLastNameUnderlineView: UIView!
    @IBOutlet weak var firstAndLastNameStackView: UIStackView!
    
    @IBOutlet weak var voucherCodeTextField: NextResponderTextField!
    @IBOutlet weak var voucherCodeUnderlineView: UIView!
    @IBOutlet weak var voucherCodeStackView: UIStackView!
    
    @IBOutlet weak var noVoucherInfoLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    var applicationContext: F4SApplicationContext?
    var datePicker = UIDatePicker()
    var voucherVerificationService: F4SVoucherVerificationServiceProtocol?
    
    lazy var userService: F4SUserService = {
        return F4SUserService()
    }()
    
    lazy var dateOfBirthFormatter: DateFormatter = {
       let df = DateFormatter()
        df.dateFormat = "dd' 'MM' 'yyyy" //"yyyy'-'MM'-'dd'"
        df.dateStyle = .medium
        return df
    }()
    
    var isEmailOkay: Bool {
        guard let emailAddress = emailTextField.text else {
            return false
        }
        return emailAddress.isEmail() && !emailAddress.isEmpty
    }
    
    var isNameOkay: Bool {
        guard let fullName = firstAndLastNameTextField.text else {
            return false
        }
        return fullName.isValidName() && !fullName.isEmpty
    }
    var isVoucherOkay: Bool {
        guard let voucherText = voucherCodeTextField.text else {
            return true
        }
        return voucherText.isEmpty || (voucherText.isVoucherCode() && voucherText.count == 6)
    }
    
    lazy var documentUploadController: DocumentUrlViewController = {
        let storyboard = UIStoryboard(name: "DocumentUrl", bundle: nil)
        return storyboard.instantiateInitialViewController() as! DocumentUrlViewController
    }()
    
    lazy var emailController: F4SEmailVerificationViewController = {
        let emailStoryboard = UIStoryboard(name: "F4SEmailVerification", bundle: nil)
        let emailController = emailStoryboard.instantiateViewController(withIdentifier: "EmailVerification") as! F4SEmailVerificationViewController
        return emailController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupControls()
        displayUserInfoIfExists()
        updateDOBValidityUnderlining()
        updateButtonStateAndImage()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        toYoungStackView.isHidden = true
        applyStyle()
        adjustNavigationBar()
        updateButtonStateAndImage()
    }
    
    func applyStyle() {
        F4SButtonStyler.apply(style: .primary, button: self.exploreMapButton)
        F4SButtonStyler.apply(style: .primary, button: self.completeExtraInfoButton)
    }
    
}

// MARK: - Handle keyboard
extension ExtraInfoViewController {
    
    /// Handles changes to keyboard size and position
    @objc func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
                let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                scrollView.contentInset = contentInset
                scrollView.scrollIndicatorInsets = contentInset
            } else {
                if let keyboardSize = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
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
}

// MARK: - UI Setup
extension ExtraInfoViewController {

    func setupControls() {
        setupDatePicker()
        setupTextFields()
        setupLabels()
        self.userInfoStackView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setupTextFields() {
        let dobString = NSLocalizedString("Date of birth", comment: "")
        let nameString = NSLocalizedString("First and Last Name", comment: "")
        
        let voucherString = NSLocalizedString("Voucher code (Optional)", comment: "")
        
        let placeHolderAttributes = [
            NSAttributedStringKey.foregroundColor: UIColor(netHex: Colors.pinkishGrey),
            NSAttributedStringKey.font: UIFont.f4sSystemFont(size: Style.biggerMediumTextSize, weight: UIFont.Weight.regular),
            ]
        let inputStringAttributes: [String: Any] = [
            NSAttributedStringKey.foregroundColor.rawValue: UIColor(netHex: Colors.black),
            NSAttributedStringKey.font.rawValue: UIFont.f4sSystemFont(size: Style.biggerMediumTextSize, weight: UIFont.Weight.regular)]
        
        dobTextField.attributedPlaceholder = NSAttributedString(string: dobString, attributes: placeHolderAttributes)
        firstAndLastNameTextField.attributedPlaceholder = NSAttributedString(string: nameString, attributes: placeHolderAttributes)
        voucherCodeTextField.attributedPlaceholder = NSAttributedString(string: voucherString, attributes: placeHolderAttributes)
        dobTextField.defaultTextAttributes = inputStringAttributes
        firstAndLastNameTextField.defaultTextAttributes = inputStringAttributes
        voucherCodeTextField.defaultTextAttributes = inputStringAttributes
        
        dobTextField.inputView = datePicker
        
        updateDOBValidityUnderlining()
        self.emailUnderlineView.backgroundColor = UIColor(netHex: Colors.orangeYellow)
        self.firstAndLastNameUnderlineView.backgroundColor = UIColor(netHex: Colors.orangeYellow)
        self.voucherCodeUnderlineView.backgroundColor = UIColor(netHex: Colors.warmGrey)
        self.voucherCodeStackView.isHidden = true
    }
    
    func setupLabels() {
        let dobInfoString1 = NSLocalizedString("When were you born? And ", comment: "")
        let dobInfoString2 = NSLocalizedString("why do we need to know?", comment: "")
        let voucherString1 = NSLocalizedString("If you don’t have a voucher code ", comment: "")
        let voucherString2 = NSLocalizedString("tap here", comment: "")
        
        let infoAttributes = [
            NSAttributedStringKey.foregroundColor: UIColor(netHex: Colors.warmGrey),
            NSAttributedStringKey.font: UIFont.f4sSystemFont(size: Style.smallTextSize, weight: UIFont.Weight.regular),
            ]
        let semiBoldInfoAttributes = [
            NSAttributedStringKey.foregroundColor: UIColor(netHex: Colors.warmGrey),
            NSAttributedStringKey.font: UIFont.f4sSystemFont(size: Style.smallTextSize, weight: UIFont.Weight.semibold),
            ]
        
        let dobInfoString1Attr = NSAttributedString(string: dobInfoString1,
                                                    attributes: infoAttributes)
        let dobInfoString2Attr = NSAttributedString(string: dobInfoString2,
                                                    attributes: semiBoldInfoAttributes)
        
        let voucherString1Attr = NSAttributedString(string: voucherString1,
                                                    attributes: infoAttributes)
        let voucherString2Attr = NSAttributedString(string: voucherString2,
                                                    attributes: semiBoldInfoAttributes)
        
        let voucherConcatInfoString = NSMutableAttributedString(attributedString: voucherString1Attr)
        let dobConcatInfoString = NSMutableAttributedString(attributedString: dobInfoString1Attr)
        
        voucherConcatInfoString.append(voucherString2Attr)
        dobConcatInfoString.append(dobInfoString2Attr)
        
        dobInfoLabel.attributedText = dobConcatInfoString
        dobInfoLabel.isUserInteractionEnabled = true
        noVoucherInfoLabel.attributedText = voucherConcatInfoString
        noVoucherInfoLabel.isUserInteractionEnabled = true
        
        let dobInfoLabelTap = UITapGestureRecognizer(target: self, action: #selector(didTapDobInfoLabel))
        let noVoucherInfoLabelTap = UITapGestureRecognizer(target: self, action: #selector(didTapNoVoucherInfoLabel))
        dobInfoLabelTap.numberOfTapsRequired = 1
        noVoucherInfoLabelTap.numberOfTapsRequired = 1
        
        dobInfoLabel.addGestureRecognizer(dobInfoLabelTap)
        noVoucherInfoLabel.addGestureRecognizer(noVoucherInfoLabelTap)
    }
    
    func setupDatePicker() {
        let currentDate = Date()
        
        datePicker.datePickerMode = .date
        datePicker.backgroundColor = UIColor(netHex: Colors.white)
        datePicker.maximumDate = currentDate
        
        let calendar = NSCalendar.current
        var dateComponents = calendar.dateComponents([.year], from: currentDate)
        dateComponents.year = dateComponents.year! - 16
        dateComponents.month = 1
        dateComponents.day = 1
        if let defaultDate = calendar.date(from: dateComponents) {
            datePicker.setDate(defaultDate, animated: false)
        }
        
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(netHex: Colors.mediumGreen)
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneButtonTouched))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButtonTouched))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        dobTextField.inputAccessoryView = toolBar
    }
    
    func adjustNavigationBar() {
        UIApplication.shared.statusBarStyle = .default
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.navigationBar.barTintColor = UIColor(netHex: Colors.black)
        navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.isTranslucent = false
    }
    
    func consentGiven() -> Bool {
        let previousConsent = consentPreviouslyGiven()
        let currentConsent = consentGiventSwitch.isOn
        return currentConsent || previousConsent
    }
    
    func consentPreviouslyGiven() -> Bool {
        return UserDefaults.standard.bool(forKey: consentPreviouslyGivenKey)
    }
    
    func displayUserInfoIfExists() {
        if let user = UserInfoDBOperations.sharedInstance.getUserInfo() {
            self.infoStackViewTopConstraint.constant = 49
            self.userInfoStackView.isHidden = false
            self.noVoucherInfoLabel.isHidden = false
            scrollView.isScrollEnabled = true
            if let dob = user.dateOfBirth {
                self.dobTextField.text = dateOfBirthFormatter.string(from: dob)
            } else {
                self.dobTextField.text = ""
            }
            self.emailTextField.text = user.email
            self.firstAndLastNameTextField.text = user.firstName + " " + (user.lastName ?? "")
            
            self.emailUnderlineView.backgroundColor = UIColor(netHex: Colors.mediumGreen)
            self.firstAndLastNameUnderlineView.backgroundColor = UIColor(netHex: Colors.mediumGreen)
        } else {
            self.userInfoStackView.isHidden = true
            self.noVoucherInfoLabel.isHidden = true
            self.scrollView.isScrollEnabled = false
            let screenHeight = self.view.bounds.height
            let infoLabelY = self.dobInfoLabel.frame.maxY
            let stackViewHeight = self.userInfoStackView.bounds.height
            
            self.infoStackViewTopConstraint.constant = screenHeight - infoLabelY - stackViewHeight + 90
        }
        self.noVoucherInfoLabel.isHidden = self.voucherCodeStackView.isHidden
    }
    
    func getUserAge() -> Int {
        let currentdate = NSDate()
        let userBirthday = self.datePicker.date
        let calendar = NSCalendar.current
        let ageComponents = calendar.dateComponents([.year], from: userBirthday, to: currentdate as Date)
        let age = ageComponents.year!
        return age
    }
    
    func checkIfAllFieldsAreValid() -> Bool {
        guard getUserAge() >= 13 else {
            return false
        }
        return isEmailOkay && isNameOkay && isVoucherOkay
    }
    
    func getPlacementUuid() -> String {
        guard let currentCompany = self.applicationContext?.company,
            let placement = PlacementDBOperations.sharedInstance.getPlacementsForCurrentUserAndCompany(companyUuid: currentCompany.uuid) else {
                return ""
        }
        return placement.placementUuid ?? ""
    }
    
    func buildUserInfo() -> F4SUser {
        var user = F4SUser()
        if let dateOfBirthText = dobTextField.text {
            user.dateOfBirth = dateOfBirthFormatter.date(from: dateOfBirthText)
        }
        if let email = emailTextField.text {
            user.email = email
        }
        if let firstAndLastNameText = firstAndLastNameTextField.text {
            let nameComponents = firstAndLastNameText.components(separatedBy: " ")
            if nameComponents.count > 1 {
                user.firstName = nameComponents.first!
                let lastname = nameComponents.dropFirst().joined(separator: " ")
                if !lastname.isEmpty {
                    user.lastName = nameComponents.dropFirst().joined(separator: " ")
                }
            } else {
                user.firstName = nameComponents.first!
                user.lastName = nil
            }
        }
        user.placementUuid = getPlacementUuid()
        applicationContext?.user = user
        return user
    }
    
    func updateButtonStateAndImage() {
        if self.getUserAge() < 13 {
            self.toYoungStackView.isHidden = false
            self.userInfoStackView.isHidden = true
        } else {
            self.toYoungStackView.isHidden = true
            self.userInfoStackView.isHidden = false
        }
        
        emailUnderlineView.backgroundColor = isEmailOkay ? UIColor(netHex: Colors.mediumGreen) : UIColor(netHex: Colors.orangeYellow)
        
        firstAndLastNameUnderlineView.backgroundColor = isNameOkay ? UIColor(netHex: Colors.mediumGreen) : UIColor(netHex: Colors.orangeYellow)
        
        voucherCodeUnderlineView.backgroundColor = isVoucherOkay  ? UIColor(netHex: Colors.mediumGreen) : UIColor(netHex: Colors.orangeYellow)
        
        if checkIfAllFieldsAreValid()  {
            if consentPreviouslyGiven() {
                completionImageView.image = UIImage(named: "checkMark")
                completeExtraInfoButton.isEnabled = true
                acceptConditionsStackView.isHidden = true
            } else {
                completionImageView.image = UIImage(named: "yellowQuestionMark")
                completeExtraInfoButton.isEnabled = consentGiven()
                acceptConditionsStackView.isHidden = false
            }
        } else {
            completionImageView.image = UIImage(named: "yellowQuestionMark")
            completeExtraInfoButton.isEnabled = false
            acceptConditionsStackView.isHidden = true
        }
    }
}

// MARK: - UITextFieldDelegate
extension ExtraInfoViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidEndEditing(_: UITextField) {
        updateButtonStateAndImage()
    }
}

// MARK: - Calls
extension ExtraInfoViewController {
    
    func saveUserDetailsLocally() -> F4SUser {
        let updatedUser = self.buildUserInfo()
        UserInfoDBOperations.sharedInstance.saveUserInfo(userInfo: updatedUser)
        applicationContext?.user = updatedUser
        return updatedUser
    }
}

// MARK: - User Interaction
extension ExtraInfoViewController {
    
    @objc func doneButtonTouched() {
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "d MMMM yyyy"
        
        dobTextField.text = dateFormatter1.string(from: datePicker.date)
        dobTextField.resignFirstResponder()
        scrollView.isScrollEnabled = true
        self.infoStackViewTopConstraint.constant = 49
        self.updateButtonStateAndImage()
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.updateDOBValidityUnderlining()
            strongSelf.view.layoutIfNeeded()
        })
    }
    
    func updateDOBValidityUnderlining() {
        guard let dobText = dobTextField.text, !dobText.isEmpty else {
            dobUnderlineView.backgroundColor = UIColor(netHex: Colors.orangeYellow)
            return
        }
        if getUserAge() < 13 {
            dobUnderlineView.backgroundColor = UIColor(netHex: Colors.orangeYellow)
        } else {
            dobUnderlineView.backgroundColor = UIColor(netHex: Colors.mediumGreen)
        }
    }
    
    @objc func cancelButtonTouched() {
        dobTextField.resignFirstResponder()
    }
    
    @objc func didTapDobInfoLabel(recognizer: UITapGestureRecognizer) {
        guard let string = dobInfoLabel.attributedText else {
            return
        }
        
        let textStorage = NSTextStorage(attributedString: string)
        let lm = NSLayoutManager()
        textStorage.addLayoutManager(lm)
        
        let tc = NSTextContainer(size: CGSize(width: self.dobInfoLabel.bounds.width, height: self.dobInfoLabel.bounds.height))
        
        lm.addTextContainer(tc)
        tc.lineFragmentPadding = 0
        
        let toRange = (string.string as NSString).range(of: "why do we")
        let toRange2 = (string.string as NSString).range(of: "need to know?")
        
        let gr = lm.glyphRange(forCharacterRange: toRange, actualCharacterRange: nil)
        let gr2 = lm.glyphRange(forCharacterRange: toRange2, actualCharacterRange: nil)
        let glyphRect = lm.boundingRect(forGlyphRange: gr, in: tc)
        let glyphRect2 = lm.boundingRect(forGlyphRange: gr2, in: tc)
        
        let tapPoint = recognizer.location(in: self.dobInfoLabel)
        if glyphRect.contains(tapPoint) || glyphRect2.contains(tapPoint) {
            if let navigCtrl = self.navigationController {
                CustomNavigationHelper.sharedInstance.presentContentViewController(navCtrl: navigCtrl, contentType: F4SContentType.consent)
            }
        }
    }
    
    @objc func didTapNoVoucherInfoLabel(recognizer: UITapGestureRecognizer) {
        guard let string = noVoucherInfoLabel.attributedText else {
            return
        }
        
        let textStorage = NSTextStorage(attributedString: string)
        let lm = NSLayoutManager()
        textStorage.addLayoutManager(lm)
        
        let tc = NSTextContainer(size: CGSize(width: self.noVoucherInfoLabel.bounds.width, height: self.noVoucherInfoLabel.bounds.height))
        
        lm.addTextContainer(tc)
        tc.lineFragmentPadding = 0
        
        let toRange = (string.string as NSString).range(of: "tap here")
        
        let gr = lm.glyphRange(forCharacterRange: toRange, actualCharacterRange: nil)
        var glyphRect = lm.boundingRect(forGlyphRange: gr, in: tc)
        glyphRect.size.height += 44
        glyphRect.size.width += 22
        
        let tapPoint = recognizer.location(in: self.noVoucherInfoLabel)
        if glyphRect.contains(tapPoint) {
            if let navigCtrl = self.navigationController {
                CustomNavigationHelper.sharedInstance.presentContentViewController(navCtrl: navigCtrl, contentType: F4SContentType.voucher)
            }
        }
    }
    
    @IBAction func emailTextFieldDidChange(_ sender: NextResponderTextField) {
        updateButtonStateAndImage()
    }
    
    @IBAction func firstNameAndLastNameTextFieldDidChange(_ sender: NextResponderTextField) {
        updateButtonStateAndImage()
    }
    
    @IBAction func voucherCodeTextFieldDidChange(_ sender: NextResponderTextField) {
        updateButtonStateAndImage()
    }
    
    @IBAction func completeInfoButtonTouched(_: UIButton) {
        self.view.endEditing(true)
        let user = saveUserDetailsLocally()
        guard var applicationContext = applicationContext else { return }
        applicationContext.user = user
//        if let reachability = Reachability() {
//            if !reachability.isReachableByAnyMeans {
//                MessageHandler.sharedInstance.display("No Internet Connection.", parentCtrl: self)
//                return
//            }
//        }
        verifyVoucher(applicationContext: applicationContext)
    }
    
    func verifyVoucher(applicationContext: F4SApplicationContext) {
        guard let voucherCode = voucherCodeTextField.text, voucherCode.isEmpty == false  else {
            afterVoucherValidation(applicationContext: applicationContext)
            return
        }
        if voucherVerificationService == nil {
            let placementUuid = applicationContext.user!.placementUuid!
            voucherVerificationService = F4SVoucherVerificationService(placementUuid: placementUuid, voucherCode: voucherCode)
        }
        showLoadingOverlay()
        voucherVerificationService?.verify(completion: { [weak self] (result) in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                strongSelf.hideLoadingOverlay()
                switch result {
                case .error(let error):
                    if error.retry {
                        strongSelf.handleRetryForNetworkError(error, retry: {
                            strongSelf.verifyVoucher(applicationContext: applicationContext)
                        })
                    } else {
                        strongSelf.handleUnrecoverableError(error)
                    }
                case .success(let voucherVerification):
                    if voucherVerification.status == "issued" {
                        strongSelf.afterVoucherValidation(applicationContext: applicationContext)
                    } else {
                        let reason = voucherVerification.errors?.status ?? NSLocalizedString("Please check your voucher code has been entered correctly", comment: "")
                        strongSelf.presentInvalidVoucherAlert(reason: reason)
                    }
                }
                strongSelf.voucherVerificationService = nil
            }
        })
    }
    
    func afterVoucherValidation(applicationContext: F4SApplicationContext) {
        getPartnersFromServer(applicationContext: applicationContext)
    }
    
    func afterVoucherUpdate(applicationContext: F4SApplicationContext) {
        getPartnersFromServer(applicationContext: applicationContext)
    }
    
    func getPartnersFromServer(applicationContext: F4SApplicationContext) {
        showLoadingOverlay()
        F4SPartnersModel.sharedInstance.getPartnersFromServer { [weak self] (result) in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                strongSelf.hideLoadingOverlay()
                switch result {
                case .error(let error):
                    if error.retry {
                        strongSelf.handleRetryForNetworkError(error, retry: {
                            strongSelf.getPartnersFromServer(applicationContext: applicationContext)
                        })
                    }
                case .success(_):
                    strongSelf.afterGetPartners(applicationContext: applicationContext)
                }
            }
        }
    }
    
    func afterGetPartners(applicationContext: F4SApplicationContext) {
        verifyEmail(applicationContext: applicationContext)
    }
    
    func verifyEmail(applicationContext: F4SApplicationContext) {
        let emailController = self.emailController
        let emailModel = emailController.model
        let user = applicationContext.user!
        
        if emailModel.isEmailAddressVerified(email: user.email) {
            afterEmailVerfied(applicationContext: applicationContext)
        } else {
            emailController.emailToVerify = user.email
            emailController.model.restart()
            emailController.emailWasVerified = { [weak self] in
                guard let strongSelf = self else { return }
                DispatchQueue.main.async {
                    strongSelf.emailTextField.text = emailController.model.verifiedEmail
                    _ = strongSelf.saveUserDetailsLocally()
                    strongSelf.afterEmailVerfied(applicationContext: applicationContext)
                }
            }
            self.navigationController!.pushViewController(emailController, animated: true)
        }
    }
    
    func afterEmailVerfied(applicationContext: F4SApplicationContext) {
        performDocumentUpload(applicationContext: applicationContext)
    }
    
    func performDocumentUpload(applicationContext: F4SApplicationContext) {
        let uploadController = documentUploadController
        uploadController.applicationContext = self.applicationContext
        uploadController.completion = { [weak self] applicationContext in
            DispatchQueue.main.async {
                self?.afterDocumentUpload(applicationContext: applicationContext)
            }
        }
        self.navigationController?.pushViewController(uploadController, animated: true)
    }
    
    func afterDocumentUpload(applicationContext: F4SApplicationContext) {
        submitApplication(applicationContext: applicationContext)
    }
    
    func submitApplication(applicationContext: F4SApplicationContext) {
        showLoadingOverlay()
        var user = applicationContext.user!
        userService.updateUser(user: user) { [weak self] (result) in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                strongSelf.hideLoadingOverlay()
                switch result {
                case .success(let userModel):
                    guard let uuid = userModel.uuid else {
                        MessageHandler.sharedInstance.displayWithTitle("Oops something went wrong", "Workfinder cannot complete this operation", parentCtrl: strongSelf)
                        return
                    }
                    user.updateUuidAndPersistToLocalStorage(uuid: uuid)
                   // Ensure session manager is aware of the possible change if user uuid F4SNetworkSessionManager.shared.rebuildSessions()
                    var updatedContext = applicationContext
                    updatedContext.user = user
                    var updatedPlacement = applicationContext.placement!
                    updatedPlacement.status = F4SPlacementStatus.applied
                    updatedContext.placement = updatedPlacement
                    strongSelf.applicationContext = updatedContext
                    PlacementDBOperations.sharedInstance.savePlacement(placement: updatedPlacement)
                    UserDefaults.standard.set(true, forKey: strongSelf.consentPreviouslyGivenKey)
                    strongSelf.afterSubmitApplication(applicationContext: updatedContext)
                case .error(let error):
                    strongSelf.handleRetryForNetworkError(error, retry: {
                        strongSelf.submitApplication(applicationContext: applicationContext)
                    })
                }
            }
        }
    }
    
    func afterSubmitApplication(applicationContext: F4SApplicationContext) {
        CustomNavigationHelper.sharedInstance.presentSuccessExtraInfoPopover(
            parentCtrl: documentUploadController)
    }
}

extension ExtraInfoViewController {
    
    func showLoadingOverlay() {
        MessageHandler.sharedInstance.showLoadingOverlay(self.view)
    }
    func hideLoadingOverlay() {
        MessageHandler.sharedInstance.hideLoadingOverlay()
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
        MessageHandler.sharedInstance.display(error, parentCtrl: self, cancelHandler: nil) {
            retry()
        }
    }
    
    func handleUnrecoverableError(_ error: Error) {
        MessageHandler.sharedInstance.hideLoadingOverlay()
        MessageHandler.sharedInstance.display(error.localizedDescription, parentCtrl: self)
    }
}
