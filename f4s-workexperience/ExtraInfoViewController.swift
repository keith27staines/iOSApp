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
            CustomNavigationHelper.sharedInstance.presentContentViewController(navCtrl: navigCtrl, contentType: ContentType.terms)
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
        adjustAppearence()
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

    func adjustAppearence() {
        setupDatePicker()
        setupTextFields()
        setupLabels()

        self.userInfoStackView.translatesAutoresizingMaskIntoConstraints = false
        displayUserInfoIfExists()
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
            self.dobTextField.text = user.dateOfBirth
            self.emailTextField.text = user.email
            self.firstAndLastNameTextField.text = user.firstName + " " + user.lastName

            self.emailUnderlineView.backgroundColor = UIColor(netHex: Colors.mediumGreen)
            self.firstAndLastNameUnderlineView.backgroundColor = UIColor(netHex: Colors.mediumGreen)
            updateDOBValidityUnderlining()
            updateButtonStateAndImage()
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
        guard let voucherCodeTextFieldText = voucherCodeTextField.text else {
            return false
        }

        let validColor = UIColor(netHex: Colors.mediumGreen)

        if self.emailUnderlineView.backgroundColor == validColor &&
            self.firstAndLastNameUnderlineView.backgroundColor == validColor {
            if voucherCodeTextFieldText.isEmpty {
                return true
            } else {
                if voucherCodeUnderlineView.backgroundColor == validColor { return true } else { return false }
            }
        }
        return false
    }

    func getPlacementUuid() -> String {
        guard let currentCompany = self.applicationContext?.company,
            let placement = PlacementDBOperations.sharedInstance.getPlacementsForCurrentUserAndCompany(companyUuid: currentCompany.uuid) else {
            return ""
        }
        return placement.placementUuid
    }

    func savePlacementLocally(status: PlacementStatus ) {
        guard let currentCompany = self.applicationContext?.company,
            let placement = PlacementDBOperations.sharedInstance.getPlacementsForCurrentUserAndCompany(companyUuid: currentCompany.uuid) else {
            return
        }
        var updatedPlacement = placement
        updatedPlacement.status = status
        applicationContext?.placement = placement
        PlacementDBOperations.sharedInstance.savePlacement(placement: updatedPlacement)
    }

    func buildUserInfo() -> User {
        var user = User()
        if let dateOfBirthText = dobTextField.text {
            user.dateOfBirth = dateOfBirthText
        }
        if let email = emailTextField.text {
            user.email = email
        }
        if let firstAndLastNameText = firstAndLastNameTextField.text {
            let nameComponents = firstAndLastNameText.components(separatedBy: " ")
            if nameComponents.count > 1 {
                user.firstName = nameComponents.first!
                user.lastName = nameComponents.dropFirst().joined(separator: " ")
            } else {
                user.firstName = nameComponents.first!
                user.lastName = ""
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

    func saveUserDetailsLocally() -> User {
        let updatedUser = self.buildUserInfo()
        UserInfoDBOperations.sharedInstance.saveUserInfo(userInfo: updatedUser)
        applicationContext?.user = updatedUser
        return updatedUser
    }
    
    func updateVoucher(voucherCode: String, user: User, completion: @escaping (Result<String>) -> ()) {
        MessageHandler.sharedInstance.showLoadingOverlay(self.view)
        VoucherService.sharedInstance.validateVoucher(voucherCode: voucherCode, placementUuid: user.placementUuid, putCompleted: { success, result  in
            completion(result)
        })
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
                CustomNavigationHelper.sharedInstance.presentContentViewController(navCtrl: navigCtrl, contentType: ContentType.consent)
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
                CustomNavigationHelper.sharedInstance.presentContentViewController(navCtrl: navigCtrl, contentType: ContentType.voucher)
            }
        }
    }

    @IBAction func emailTextFieldDidChange(_ sender: NextResponderTextField) {
        if let senderText = sender.text {
            if senderText.isEmail() && !senderText.isEmpty {
                self.emailUnderlineView.backgroundColor = UIColor(netHex: Colors.mediumGreen)
            } else {
                self.emailUnderlineView.backgroundColor = UIColor(netHex: Colors.orangeYellow)
            }
        }
        updateButtonStateAndImage()
    }

    @IBAction func firstNameAndLastNameTextFieldDidChange(_ sender: NextResponderTextField) {
        if let senderText = sender.text {
            if senderText.isValidName() && !senderText.isEmpty {
                self.firstAndLastNameUnderlineView.backgroundColor = UIColor(netHex: Colors.mediumGreen)
            } else {
                self.firstAndLastNameUnderlineView.backgroundColor = UIColor(netHex: Colors.orangeYellow)
            }
        }
        updateButtonStateAndImage()
    }

    @IBAction func voucherCodeTextFieldDidChange(_ sender: NextResponderTextField) {
        if let senderText = sender.text {
            if senderText.isVoucherCode() && senderText.count == 6 {
                self.voucherCodeUnderlineView.backgroundColor = UIColor(netHex: Colors.mediumGreen)
            }
            if senderText.count != 6 {
                self.voucherCodeUnderlineView.backgroundColor = UIColor(netHex: Colors.orangeYellow)
            }
            if senderText.count == 0 {
                self.voucherCodeUnderlineView.backgroundColor = UIColor(netHex: Colors.warmGrey)
            }
        }
        if checkIfAllFieldsAreValid() {
            completionImageView.image = UIImage(named: "checkMark")
            completeExtraInfoButton.isEnabled = true
        } else {
            completionImageView.image = UIImage(named: "yellowQuestionMark")
            completeExtraInfoButton.isEnabled = false
        }
        updateButtonStateAndImage()
    }

    @IBAction func completeInfoButtonTouched(_: UIButton) {
        self.view.endEditing(true)
        let user = saveUserDetailsLocally()
        applicationContext?.user = user
        if let reachability = Reachability() {
            if !reachability.isReachableByAnyMeans {
                MessageHandler.sharedInstance.display("No Internet Connection.", parentCtrl: self)
                return
            }
        }
        
        if let voucher = voucherCodeTextField.text, voucher.isEmpty == false {
            updateVoucher(voucherCode: voucher, user: user) { [weak self] result in
                self?.afterVoucherUpdate(result: result, user: user)
            }
        } else {
            getPartnersFromServer(user: user)
        }
    }
    
    func afterVoucherUpdate(result: Result<String>, user: User) {
        if let _ = continueWithResult(result: result) {
            getPartnersFromServer(user: user)
        }
    }
    
    func getPartnersFromServer(user: User) {
        PartnersModel.sharedInstance.getPartnersFromServer { [weak self] (success) in
            self?.afterGetPartners(success: success, user: user)
        }
    }
    
    func afterGetPartners(success: Bool, user: User) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            let emailController = strongSelf.emailController
            let emailModel = emailController.model
            if emailModel.isEmailAddressVerified(email: user.email) {
                strongSelf.gotoDocumentUpload()
            } else {
                strongSelf.emailController.model.restart()
                strongSelf.emailController.emailToVerify = user.email
                strongSelf.emailController.emailWasVerified = {
                    strongSelf.emailTextField.text = emailController.model.verifiedEmail
                    _ = strongSelf.saveUserDetailsLocally()
                    strongSelf.gotoDocumentUpload()
                }
                strongSelf.navigationController!.pushViewController(emailController, animated: true)
            }
        }
    }
    
    func gotoDocumentUpload() {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            let uploadController = strongSelf.documentUploadController
            uploadController.applicationContext = self?.applicationContext
            uploadController.completion = { applicationContext in
                strongSelf.gotoSucess(applicationContext: applicationContext, parent: uploadController)
            }
            strongSelf.navigationController?.pushViewController(uploadController, animated: true)
        }
    }
    
    func gotoSucess(applicationContext: F4SApplicationContext, parent: UIViewController) {
        UserService.sharedInstance.updateUser(user: applicationContext.user!, putCompleted: { [weak self] (success, result) in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                strongSelf.savePlacementLocally(status: .applied)
                UserDefaults.standard.set(true, forKey: strongSelf.consentPreviouslyGivenKey)
                if let _ = strongSelf.continueWithResult(result: result) {
                    CustomNavigationHelper.sharedInstance.presentSuccessExtraInfoPopover(parentCtrl: parent)
                }
            }
        })
    }
    
    func continueWithResult(result: Result<String>?) -> Result<String>? {
        guard let result = result else {
            MessageHandler.sharedInstance.hideLoadingOverlay()
            return nil
        }
        switch result {
        case .value:
            return result
        case .deffinedError(let definedError):
            MessageHandler.sharedInstance.hideLoadingOverlay()
            MessageHandler.sharedInstance.display(definedError, parentCtrl: self)
            
        case .error(let error):
            MessageHandler.sharedInstance.hideLoadingOverlay()
            MessageHandler.sharedInstance.display(error, parentCtrl: self)
        }
        return nil
    }
}
