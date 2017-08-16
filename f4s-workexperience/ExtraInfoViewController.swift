//
//  ExtraInfoViewController.swift
//  f4s-workexperience
//
//  Created by Sergiu Simon on 11/12/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import UIKit
import ReachabilitySwift

class ExtraInfoViewController: UIViewController {

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

    @IBOutlet weak var parentsEmailTextField: NextResponderTextField!
    @IBOutlet weak var parentsEmailUnderlineView: UIView!
    @IBOutlet weak var parentsEmailStackView: UIStackView!

    @IBOutlet weak var voucherCodeTextField: NextResponderTextField!
    @IBOutlet weak var voucherCodeUnderlineView: UIView!
    @IBOutlet weak var voucherCodeStackView: UIStackView!

    @IBOutlet weak var noVoucherInfoLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!

    var currentCompany: Company?
    var datePicker = UIDatePicker()
    var keyboardNotification: KeyboardNotfifications!

    override func viewDidLoad() {
        super.viewDidLoad()
        adjustAppearence()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        adjustNavigationBar()
        self.keyboardNotification = KeyboardNotfifications(scrollView: self.scrollView, textField: self.emailTextField, view: self.contentView)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.keyboardNotification.removeObserver()
    }
}

// MARK: - UI Setup
extension ExtraInfoViewController {

    func adjustAppearence() {
        setupDatePicker()
        setupTextFields()
        setupLabels()
        setupButton()

        self.userInfoStackView.translatesAutoresizingMaskIntoConstraints = false
        displayUserInfoIfExists()
    }

    func setupButton() {
        self.completeExtraInfoButton.layer.masksToBounds = true
        self.completeExtraInfoButton.adjustsImageWhenHighlighted = false
        self.completeExtraInfoButton.layer.cornerRadius = 10
        self.completeExtraInfoButton.setBackgroundColor(color: UIColor(netHex: Colors.lightGreen), forUIControlState: .highlighted)
        self.completeExtraInfoButton.setBackgroundColor(color: UIColor(netHex: Colors.whiteGreen), forUIControlState: .disabled)
        self.completeExtraInfoButton.setBackgroundColor(color: UIColor(netHex: Colors.mediumGreen), forUIControlState: .normal)
        self.completeExtraInfoButton.isEnabled = false
        self.completeExtraInfoButton.setTitleColor(UIColor.white, for: .normal)
        self.completeExtraInfoButton.setTitleColor(UIColor.white, for: .highlighted)
    }

    func setupTextFields() {
        let dobString = NSLocalizedString("Date of birth", comment: "")
        let nameString = NSLocalizedString("First and Last Name", comment: "")
        let parentsEmailString = NSLocalizedString("Parent's, teacher's or guardian's email", comment: "")
        let voucherString = NSLocalizedString("Voucher code (Optional)", comment: "")

        let placeHolderAttributes = [
            NSForegroundColorAttributeName: UIColor(netHex: Colors.pinkishGrey),
            NSFontAttributeName: UIFont.f4sSystemFont(size: Style.biggerMediumTextSize, weight: UIFontWeightRegular),
        ]
        let inputStringAttributes = [
            NSForegroundColorAttributeName: UIColor(netHex: Colors.black),
            NSFontAttributeName: UIFont.f4sSystemFont(size: Style.biggerMediumTextSize, weight: UIFontWeightRegular),
        ]

        dobTextField.attributedPlaceholder = NSAttributedString(string: dobString, attributes: placeHolderAttributes)
        firstAndLastNameTextField.attributedPlaceholder = NSAttributedString(string: nameString, attributes: placeHolderAttributes)
        parentsEmailTextField.attributedPlaceholder = NSAttributedString(string: parentsEmailString, attributes: placeHolderAttributes)
        voucherCodeTextField.attributedPlaceholder = NSAttributedString(string: voucherString, attributes: placeHolderAttributes)
        dobTextField.defaultTextAttributes = inputStringAttributes
        firstAndLastNameTextField.defaultTextAttributes = inputStringAttributes
        parentsEmailTextField.defaultTextAttributes = inputStringAttributes
        voucherCodeTextField.defaultTextAttributes = inputStringAttributes

        dobTextField.inputView = datePicker

        self.dobUnderlineView.backgroundColor = UIColor(netHex: Colors.orangeYellow)
        self.emailUnderlineView.backgroundColor = UIColor(netHex: Colors.orangeYellow)
        self.firstAndLastNameUnderlineView.backgroundColor = UIColor(netHex: Colors.orangeYellow)
        self.parentsEmailUnderlineView.backgroundColor = UIColor(netHex: Colors.orangeYellow)
        self.voucherCodeUnderlineView.backgroundColor = UIColor(netHex: Colors.warmGrey)
    }

    func setupLabels() {
        let dobInfoString1 = NSLocalizedString("When were you born? And ", comment: "")
        let dobInfoString2 = NSLocalizedString("why do we need to know?", comment: "")
        let voucherString1 = NSLocalizedString("If you don’t have a voucher code ", comment: "")
        let voucherString2 = NSLocalizedString("tap here", comment: "")

        let infoAttributes = [
            NSForegroundColorAttributeName: UIColor(netHex: Colors.warmGrey),
            NSFontAttributeName: UIFont.f4sSystemFont(size: Style.smallTextSize, weight: UIFontWeightRegular),
        ]
        let semiBoldInfoAttributes = [
            NSForegroundColorAttributeName: UIColor(netHex: Colors.warmGrey),
            NSFontAttributeName: UIFont.f4sSystemFont(size: Style.smallTextSize, weight: UIFontWeightSemibold),
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

    func displayUserInfoIfExists() {
        if let user = UserInfoDBOperations.sharedInstance.getUserInfo() {
            self.infoStackViewTopConstraint.constant = 49
            self.userInfoStackView.isHidden = false
            self.noVoucherInfoLabel.isHidden = false
            scrollView.isScrollEnabled = true
            self.dobTextField.text = user.dateOfBirth
            self.emailTextField.text = user.email
            self.firstAndLastNameTextField.text = user.firstName + " " + user.lastName
            if user.requiresConsent {
                self.parentsEmailTextField.text = user.consenterEmail
                displayExtraInfoForUser(withAge: 1)
                self.parentsEmailUnderlineView.backgroundColor = UIColor(netHex: Colors.mediumGreen)
            } else {
                displayExtraInfoForUser(withAge: 20)
            }

            self.emailUnderlineView.backgroundColor = UIColor(netHex: Colors.mediumGreen)
            self.firstAndLastNameUnderlineView.backgroundColor = UIColor(netHex: Colors.mediumGreen)

            if checkIfAllFieldsAreValid() {
                completionImageView.image = UIImage(named: "checkMark")
                completeExtraInfoButton.isEnabled = true
            } else {
                completionImageView.image = UIImage(named: "yellowQuestionMark")
                completeExtraInfoButton.isEnabled = false
            }
        } else {
            self.userInfoStackView.isHidden = true
            self.noVoucherInfoLabel.isHidden = true
            self.scrollView.isScrollEnabled = false
            let screenHeight = self.view.bounds.height
            let infoLabelY = self.dobInfoLabel.frame.maxY
            let stackViewHeight = self.userInfoStackView.bounds.height

            self.infoStackViewTopConstraint.constant = screenHeight - infoLabelY - stackViewHeight + 90
        }
    }

    func displayExtraInfoForUser(withAge: Int) {

        self.dobUnderlineView.backgroundColor = UIColor(netHex: Colors.mediumGreen)
        self.noVoucherInfoLabel.isHidden = false

        switch withAge {
        case 0 ..< 16:
            self.parentsEmailStackView.isHidden = false
        self.firstAndLastNameTextField.nextResponderField = self.parentsEmailTextField
        self.parentsEmailTextField.nextResponderField = self.voucherCodeTextField

        default:
            self.parentsEmailStackView.isHidden = true
            self.firstAndLastNameTextField.nextResponderField = self.voucherCodeTextField
        }
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
        guard let voucherCodeTextFieldText = voucherCodeTextField.text else {
            return false
        }

        let validColor = UIColor(netHex: Colors.mediumGreen)

        switch self.parentsEmailStackView.isHidden {

        case true:
            if self.emailUnderlineView.backgroundColor == validColor &&
                self.firstAndLastNameUnderlineView.backgroundColor == validColor {
                if voucherCodeTextFieldText.isEmpty {
                    return true
                } else {
                    if voucherCodeUnderlineView.backgroundColor == validColor { return true } else { return false }
                }
            } else { return false }

        case false:
            if self.emailUnderlineView.backgroundColor == validColor &&
                self.firstAndLastNameUnderlineView.backgroundColor == validColor &&
                self.parentsEmailUnderlineView.backgroundColor == validColor {
                if voucherCodeTextFieldText.isEmpty {
                    return true
                } else {
                    if voucherCodeUnderlineView.backgroundColor == validColor { return true } else { return false }
                }
            } else { return false }
        }
    }

    func getPlacementUuid() -> String {
        guard let currentCompany = self.currentCompany,
            let placement = PlacementDBOperations.sharedInstance.getPlacementsForCurrentUserAndCompany(companyUuid: currentCompany.uuid) else {
            return ""
        }
        return placement.placementUuid
    }

    func updatePlacement() {
        guard let currentCompany = self.currentCompany,
            let placement = PlacementDBOperations.sharedInstance.getPlacementsForCurrentUserAndCompany(companyUuid: currentCompany.uuid) else {
            return
        }
        var updatedPlacement = placement
        updatedPlacement.status = .applied
        PlacementDBOperations.sharedInstance.savePlacemnt(placement: updatedPlacement)
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
        if self.parentsEmailStackView.isHidden {
            user.requiresConsent = false
            user.consenterEmail = ""
        } else {
            user.requiresConsent = true
            if let parentsEmailText = parentsEmailTextField.text {
                user.consenterEmail = parentsEmailText
            }
        }
        user.placementUuid = getPlacementUuid()
        return user
    }

    func updateButtonStateAndImage() {
        if checkIfAllFieldsAreValid() {
            completionImageView.image = UIImage(named: "checkMark")
            completeExtraInfoButton.isEnabled = true
        } else {
            completionImageView.image = UIImage(named: "yellowQuestionMark")
            completeExtraInfoButton.isEnabled = false
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

    func updateUserProfile(voucherCode: String?) {
        MessageHandler.sharedInstance.showLoadingOverlay(self.view)

        let updatedUser = self.buildUserInfo()
        guard let currentVoucherCode = voucherCode else {
            updateUser(updatedUser: updatedUser)
            return
        }

        VoucherService.sharedInstance.validateVoucher(voucherCode: currentVoucherCode, placementUuid: updatedUser.placementUuid, putCompleted: {
            [weak self]
            _, result in
            guard let strongSelf = self else {
                return
            }
            switch result {
            case .value:
                print("Voucher code validated")
                strongSelf.updateUser(updatedUser: updatedUser)

            case .deffinedError(let definedError):
                MessageHandler.sharedInstance.hideLoadingOverlay()
                MessageHandler.sharedInstance.display(definedError, parentCtrl: strongSelf)

            case .error(let error):
                MessageHandler.sharedInstance.hideLoadingOverlay()
                MessageHandler.sharedInstance.display(error, parentCtrl: strongSelf)
                break
            }
        })
    }

    func updateUser(updatedUser: User) {
        UserService.sharedInstance.updateUser(user: updatedUser, putCompleted: {
            [weak self]
            _, result in
            guard let strongSelf = self else {
                return
            }
            MessageHandler.sharedInstance.hideLoadingOverlay()
            switch result {
            case .value:
                print("userInfo updated")
                UserInfoDBOperations.sharedInstance.saveUserInfo(userInfo: updatedUser)
                strongSelf.updatePlacement()
                CustomNavigationHelper.sharedInstance.showSuccessExtraInfoPopover(parentCtrl: strongSelf)
                break

            case .deffinedError(let definedError):
                MessageHandler.sharedInstance.display(definedError, parentCtrl: strongSelf)
                break

            case .error(let error):
                MessageHandler.sharedInstance.display(error, parentCtrl: strongSelf)
                break
            }
        })
    }
}

// MARK: - User Interaction
extension ExtraInfoViewController {

    func doneButtonTouched() {
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "d MMMM yyyy"

        dobTextField.text = dateFormatter1.string(from: datePicker.date)
        dobTextField.resignFirstResponder()
        scrollView.isScrollEnabled = true
        let userAge = getUserAge()
        self.infoStackViewTopConstraint.constant = 49
        self.view.setNeedsLayout()
        self.userInfoStackView.isHidden = false
        UIView.animate(withDuration: 0.5, animations: {
            self.displayExtraInfoForUser(withAge: userAge)
            if self.checkIfAllFieldsAreValid() {
                self.completionImageView.image = UIImage(named: "checkMark")
                self.completeExtraInfoButton.isEnabled = true
            } else {
                self.completionImageView.image = UIImage(named: "yellowQuestionMark")
                self.completeExtraInfoButton.isEnabled = false
            }
        })
    }

    func cancelButtonTouched() {
        dobTextField.resignFirstResponder()
    }

    func didTapDobInfoLabel(recognizer: UITapGestureRecognizer) {
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
                CustomNavigationHelper.sharedInstance.moveToContentViewController(navCtrl: navigCtrl, contentType: ContentType.consent)
            }
        } else {
            print("tapped dobInfoLabel")
        }
    }

    func didTapNoVoucherInfoLabel(recognizer: UITapGestureRecognizer) {
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
                CustomNavigationHelper.sharedInstance.moveToContentViewController(navCtrl: navigCtrl, contentType: ContentType.voucher)
            }
        } else {
            print("tapped noVoucherInfoLabel")
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

    @IBAction func parentsEmailTextFieldDidChange(_ sender: NextResponderTextField) {
        if let senderText = sender.text {
            if senderText.isEmail() && !senderText.isEmpty {
                self.parentsEmailUnderlineView.backgroundColor = UIColor(netHex: Colors.mediumGreen)
            } else {
                self.parentsEmailUnderlineView.backgroundColor = UIColor(netHex: Colors.orangeYellow)
            }
        }
        updateButtonStateAndImage()
    }

    @IBAction func voucherCodeTextFieldDidChange(_ sender: NextResponderTextField) {
        if let senderText = sender.text {
            if senderText.isVoucherCode() && senderText.characters.count == 6 {
                self.voucherCodeUnderlineView.backgroundColor = UIColor(netHex: Colors.mediumGreen)
            }
            if senderText.characters.count != 6 {
                self.voucherCodeUnderlineView.backgroundColor = UIColor(netHex: Colors.orangeYellow)
            }
            if senderText.characters.count == 0 {
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
        if let reachability = Reachability() {
            if !reachability.isReachable {
                MessageHandler.sharedInstance.display("No Internet Connection.", parentCtrl: self)
                return
            }
        }
        var voucherCode: String?
        if self.voucherCodeUnderlineView.backgroundColor == UIColor(netHex: Colors.mediumGreen), let voucherCodeTextFieldText = voucherCodeTextField.text {
            voucherCode = voucherCodeTextFieldText
        }
        updateUserProfile(voucherCode: voucherCode)
    }
}
