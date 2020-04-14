import Foundation
import WorkfinderCommon

public class UserDetailsViewModel {
    weak var coordinator: UserDetailsCoordinator!
    weak var viewController: UserDetailsViewController?
    var userInfo: Candidate
    
    let badValueColor = UIColor(netHex: Colors.orangeYellow)
    let goodValueColor = UIColor(netHex: Colors.mediumGreen)
    let ageLogic = AgeLogic()
    let labelStrings = InformationLabelStrings()
    
    let dateOfBirthPlaceholder = NSLocalizedString("Date of birth", comment: "")
    let namePlaceholder = NSLocalizedString("First and Last Name", comment: "")
    
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

    var isDateOfBirthOK: Bool { return !ageLogic.isAgeTooYoungToApply }
    var defaultDateOfBirth: Date { return ageLogic.defaultDateOfBirth() }
    
    var isUserTooYoungStackHidden: Bool { return !ageLogic.isAgeTooYoungToApply }
    var isUserInfoStackHidden: Bool { return ageLogic.isAgeTooYoungToApply }
    var isParentEmailStackHidden: Bool { return !ageLogic.isConsentRequired }
    var isUserEmailStackHidden: Bool { return !(isParentEmailOK && ageLogic.age > 0) }
    var isFirstAndLastNameStackHidden: Bool { return isUserEmailStackHidden }

    var isAgreeTermsStackHidden: Bool {
        return !(isDateOfBirthOK && isUserEmailOK && isParentEmailOK && isNameOK)
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
    
    init(user: Candidate, coordinator: UserDetailsCoordinator) {
        self.userInfo = user
        self.namesString = user.fullName
        self.coordinator = coordinator
        self.ageLogic.dateOfBirth = user.dateOfBirth
    }

    func buildUser() -> Candidate {
        var user = self.userInfo
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
    
    var isNameOK: Bool {
        guard
            let first = userInfo.firstName?.trimmingCharacters(in: CharacterSet.whitespaces),
            let last = userInfo.lastName?.trimmingCharacters(in: CharacterSet.whitespaces),
            first.isEmpty == false,
            last.isEmpty == false else { return false }
        return true
    }
    
    func exploreMoreCompanies() {
        coordinator?.userIsTooYoung?()
    }
    
    var namesString: String?
    
    func setNames(_ names: String?) {
        namesString = names
        let nameLogic = NameLogic(nameString: names)
        userInfo.firstName = nameLogic.firstName
        userInfo.lastName = nameLogic.otherNames
    }
}









