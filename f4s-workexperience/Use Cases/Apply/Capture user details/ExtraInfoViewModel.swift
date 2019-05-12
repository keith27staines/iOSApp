import Foundation
import WorkfinderCommon

public class ExtraInfoViewModel {
    weak var coordinator: TabBarCoordinator!
    weak var viewController: ExtraInfoViewController?
    var userInfo: F4SUserInformation
    
    let badValueColor = UIColor(netHex: Colors.orangeYellow)
    let goodValueColor = UIColor(netHex: Colors.mediumGreen)
    let ageLogic = AgeLogic()
    let labelStrings = InformationLabelStrings()
    
    let dateOfBirthPlaceholder = NSLocalizedString("Date of birth", comment: "")
    let namePlaceholder = NSLocalizedString("First and Last Name", comment: "")
    let voucherPlaceholder = NSLocalizedString("Voucher code (Optional)", comment: "")
    
    var termsAgreed: Bool { return userInfo.termsAgreed }
    var userEmail: String? { return userInfo.email }
    var userEmailUnderlineColor: UIColor { return isUserEmailOK ? goodValueColor : badValueColor }
    var parentEmail: String? { return userInfo.parentEmail }
    var parentEmailUnderlineColor: UIColor { return isParentEmailOK ? goodValueColor : badValueColor }
    var dateOfBirthText: String? { return ageLogic.dateOfBirthText }
    var dateOfBirthUnderlineColor: UIColor { return ageLogic.isAgeTooYoungToApply ? badValueColor : goodValueColor }
    var dateOfBirthInformationString: NSAttributedString { return labelStrings.dateOfBirthInformationString }
    var userEMailInformationString: NSAttributedString { return labelStrings.userEmailInformationString }
    var namesInformationString: NSAttributedString { return labelStrings.namesInformationString }
    var parentEmailInformationString: NSAttributedString { return labelStrings.parentEmailInformationString }
    var voucherInformationString: NSAttributedString { return labelStrings.voucherInformationString }
    var voucher: String? { return userInfo.vouchers?.first }

    var isDateOfBirthOK: Bool { return !ageLogic.isAgeTooYoungToApply }
    var defaultDateOfBirth: Date { return ageLogic.defaultDateOfBirth() }
    
    var isUserTooYoungStackHidden: Bool { return !ageLogic.isAgeTooYoungToApply }
    var isUserInfoStackHidden: Bool { return ageLogic.isAgeTooYoungToApply }
    var isParentEmailStackHidden: Bool { return !ageLogic.isConsentRequired }
    var isUserEmailStackHidden: Bool { return !(isParentEmailOK && ageLogic.age > 0) }
    var isFirstAndLastNameStackHidden: Bool { return isUserEmailStackHidden }
    var isVoucherStackHidden: Bool { return isUserEmailStackHidden }
    var isAgreeTermsStackHidden: Bool {
        return !(isDateOfBirthOK && isUserEmailOK && isParentEmailOK && isNameOK && isVoucherOK)
    }
    
    var dateOfBirth: Date? {
        set {
            self.ageLogic.dateOfBirth = newValue
            self.userInfo.dateOfBirth = newValue
            self.userInfo.requiresConsent = ageLogic.isConsentRequired
        }
        get { return self.ageLogic.dateOfBirth }
    }
    
    var userName: String? {
        return namesString
    }
    
    lazy var dateOfBirthViewModel: DateOfBirthPickerViewModel = {
        return DateOfBirthPickerViewModel(ageLogic: ageLogic, badValueColor: badValueColor, goodValueColor: goodValueColor)
    }()
    
    init(userInformation: F4SUserInformation, coordinator: TabBarCoordinator) {
        self.userInfo = userInformation
        self.namesString = userInformation.fullName
        self.coordinator = coordinator
        self.ageLogic.dateOfBirth = userInformation.dateOfBirth
    }

    func buildUser() -> F4SUser {
        let user = F4SUser()
        user.updateFromUserInformation(self.userInfo)
        user.lastName = user.lastName ?? ""
        if user.lastName!.isEmpty { user.lastName = " "}
        return user
    }
    
    var isUserEmailOK: Bool { return (userInfo.email ?? "").isEmail() }
    
    var isParentEmailOK: Bool {
        if !ageLogic.isConsentRequired { return true }
        return (userInfo.parentEmail ?? "").isEmail()
    }
    
    var isCompleteInformationButtonEnabled: Bool { return userInfo.termsAgreed && !isAgreeTermsStackHidden }
    
    var image: UIImage { return isCompleteInformationButtonEnabled ? UIImage(named: "checkMark")! : UIImage(named: "yellowQuestionMark")! }
    
    var nameUnderlineColor: UIColor { return isNameOK ? goodValueColor : badValueColor }
    var voucherUnderlineColor: UIColor { return isVoucherOK ? goodValueColor : badValueColor }
    
    var isNameOK: Bool {
        guard
            let first = userInfo.firstName?.trimmingCharacters(in: CharacterSet.whitespaces),
            let last = userInfo.lastName?.trimmingCharacters(in: CharacterSet.whitespaces),
            first.isEmpty == false,
            last.isEmpty == false else { return false }
        return true
    }
    
    var isVoucherOK: Bool {
        guard let voucher = userInfo.vouchers?.first else { return true }
        return voucher.count == 6 && voucher.isVoucherCode()
    }
    
    func exploreMoreCompanies() {
        guard let viewController = viewController else { return }
        TabBarViewController.rewindToDrawerAndSelectTab(vc: viewController, tab: .map)
    }
    
    func setVoucherString(_ string: String?) {
        guard let voucher = string else {
            userInfo.vouchers = nil
            return
        }
        userInfo.vouchers = [voucher]
    }
    
    var namesString: String?
    
    func setNames(_ names: String?) {
        namesString = names
        guard
            let substrings = names?.trimmingCharacters(in: CharacterSet.whitespaces).split(separator: " "),
            let firstSubstring = substrings.first else {
            userInfo.firstName = nil
            userInfo.lastName = nil
            return
        }
        userInfo.firstName = String(firstSubstring).trimmingCharacters(in: CharacterSet.whitespaces)
        userInfo.lastName = substrings.dropFirst().reduce("") { (lastNames, substring) -> String in
            return lastNames + " " + String(substring)
        }.trimmingCharacters(in: CharacterSet.whitespaces)
    }
}

extension ExtraInfoViewModel {

}









