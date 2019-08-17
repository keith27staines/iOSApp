import Foundation

/// The UserData protocol defines the user information that was once held in
/// CoreData and accessed by a CoreData managed object of type UserInfoDB.
/// CoreData is no longer used to store user information but to support legacy
/// versions of iOS Workfinder, there is a data fix that checks to see if the
/// CoreData userInfoDB record still exists. If it does exist, it is converted
/// into an F4SUser and saved to a none-CoreData local store. The UserData
/// protocol exists purely to facilitate the migration of the user info out of
/// CoreData
public protocol UserData {
    var userUuid: String? { get }
    var email: String? { get }
    var firstName: String? { get }
    var lastName: String? { get }
    var consenterEmail: String? { get }
    var requiresConsent: Bool { get }
    var dateOfBirth: String? { get }
}

/// F4SUserProtocol defines user information that is held in concrete form in
/// in the reference type F4SUser and in the value type F4SUserInformation
public protocol F4SUserProtocol {
    /// The UUID of the user
    var uuid: F4SUUID? { get }
    /// The email address of the user
    var email: String? { get set }
    /// The user's first name
    var firstName: String? { get set }
    /// The user's last name (or combination of second and later names)
    var lastName: String? { get set }
    /// The user's full name obtained by concatenating the first and last names
    var fullName: String? { get }
    /// The email address of the user's consenter (parent or guardian), used only if the user is under-age
    var consenterEmail: String? { get set }
    /// Possibly redundant version of consenter email
    var parentEmail: String? { get set }
    /// A flag that indicates the user must obtain consent (typically because they are under-age)
    var requiresConsent: Bool { get set }
    /// The user's date of birth
    var dateOfBirth: Date? { get set }
    /// Indicates whether the user has been given a uuid by the server
    var isRegistered: Bool { get }
    /// Indicates whether the user has finished the onboarding process
    var isOnboarded: Bool { get }
    /// An array of vouchers the user has used (rules about this are undefined as of 2019-08-07
    var vouchers: [F4SUUID]? { get set }
    /// An array of partners (people or institutions) who suggested Workfinder to the YP
    var partners: [F4SUUIDDictionary]? { get set }
    /// True if the user has acitvely accepted the terms and conditions, false otherwise
    var termsAgreed: Bool { get set }
    /// Used to update the user uuid if an account merge takes place
    mutating func updateUuid(uuid: F4SUUID)
}

public extension F4SUserProtocol {
    /// A careful implementation to derive the user's full name from their first
    /// and last name
    var fullName: String? {
        let firstName = self.firstName ?? ""
        let lastName = self.lastName ?? ""
        var name = firstName
        if (!firstName.isEmpty && !lastName.isEmpty) { name = name + " "}
        name = name + lastName
        return name.isEmpty ? nil : name
    }
}

/// F4SUserInformation provides a concrete implementation of F4SUserProtocol and
/// is intended to facilitate passing round user information in value rather
/// than reference form
public struct F4SUserInformation : F4SUserProtocol {
    public private (set) var uuid: F4SUUID?
    public var email: String?
    public var firstName: String?
    public var lastName: String?
    public var consenterEmail: String?
    public var parentEmail: String?
    public var requiresConsent: Bool = false
    public var dateOfBirth: Date?
    public var isRegistered: Bool = false
    public var isOnboarded: Bool = false
    public var vouchers: [F4SUUID]?
    public var partners: [F4SUUIDDictionary]?
    public var termsAgreed: Bool = false
    public mutating func updateUuid(uuid: F4SUUID) { self.uuid = uuid }
    
    /// Initialises a new instance with the specified values
    ///
    /// - Parameters:
    ///   - uuid: The UUID of the user
    ///   - consenterEmail: The email address of the user's consenter (parent or guardian), used only if the user is under-age
    ///   - parentEmail: Possibly redundant version of consenter email
    ///   - dateOfBirth: The user's date of birth
    ///   - email: The email address of the user
    ///   - firstName: The user's first name
    ///   - lastName: The user's last name (or combination of second and later names)
    ///   - requiresConsent: A flag that indicates the user must obtain consent (typically because they are under-age)
    ///   - termsAgreed: True if the user has acitvely accepted the terms and conditions, false otherwise
    ///   - vouchers: An array of vouchers the user has used (rules about this are undefined as of 2019-08-07
    ///   - partners: An array of partners (people or institutions) who suggested Workfinder to the YP
    ///   - isOnboarded: Indicates whether the user has finished the onboarding process
    ///   - isRegistered: Indicates whether the user has been given a uuid by the server
    public init(
        uuid: String? = nil,
        consenterEmail: String? = nil,
        parentEmail: String? = nil,
        dateOfBirth: Date? = nil,
        email: String? = nil,
        firstName: String? = nil,
        lastName: String? = nil,
        requiresConsent: Bool = false,
        termsAgreed: Bool = false,
        vouchers: [F4SUUID]? = nil,
        partners: [F4SUUIDDictionary]? = nil,
        isOnboarded: Bool = false,
        isRegistered: Bool = false
        ) {
        self.uuid = uuid
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.consenterEmail = consenterEmail
        self.parentEmail = parentEmail
        self.termsAgreed = termsAgreed
        self.dateOfBirth = dateOfBirth
        self.isRegistered = isRegistered
        self.isOnboarded = isOnboarded
        self.vouchers = vouchers
        self.partners = partners
        self.requiresConsent = requiresConsent
    }
}

/// F4SUser represents the current user (assumed to be the only user)
public class F4SUser : F4SUserProtocol, Codable {
    var localStore: LocalStorageProtocol = UserDefaults.standard
    var analytics: F4SAnalytics?
    public var placementUuid: F4SUUID?
    
    // MARK:- implementation of F4SUserProtocol
    public private (set) var uuid: F4SUUID?
    public var email: String?
    public var firstName: String?
    public var lastName: String?
    public var consenterEmail: String?
    public var parentEmail: String?
    public var requiresConsent: Bool = false
    public var dateOfBirth: Date?
    public var isRegistered: Bool { return uuid != nil }
    public var isOnboarded: Bool {
        guard let isFirstLaunch = localStore.value(key: LocalStore.Key.isFirstLaunch) as? Bool else { return false }
        return !isFirstLaunch
    }
    public var vouchers: [F4SUUID]?
    public var partners: [F4SUUIDDictionary]?
    public var termsAgreed: Bool = false
    
    public func updateUuid(uuid: F4SUUID) {
        self.uuid = uuid
        analytics?.alias(userId: uuid)
    }
    // MARK:- end of implementation of F4SUserProtocol
    
    /// Nullifies the uuid
    ///
    /// This method should be used only to prepare the instance for an http
    /// user updat request. Once the uuid is nullified, this instance should not
    /// be saved locally using the LocalStore.key.user
    public func nullifyUuid() {
        uuid = nil
    }
    
    /// Used to record the successful completion of onboarding, so that the next
    /// time the user opens the app, they won't be taken through the onboarding
    /// process again
    public func didFinishOnboarding() {
        localStore.setValue(false, for: LocalStore.Key.isFirstLaunch)
    }
    
    /// Returns the age in years of the user
    ///
    /// - Parameter date: date on which the user's age is required (defaulting to today)
    /// - Returns: the user's age on the specified date
    public func age(on date: Date = Date()) -> Int? {
        guard let userBirthday = dateOfBirth else { return nil }
        let calendar = NSCalendar.current
        let ageComponents = calendar.dateComponents([.year], from: userBirthday, to: date)
        let age = ageComponents.year!
        return age
    }
    
    /// Initialise a new instance from existing user information, essentially
    /// duplicating that information
    ///
    /// - Parameter user: the user information to duplicate in the new instance
    public init(userInformation user:F4SUserProtocol) {
        updateFrom(user)
    }
    
    /// Initialises an instance from data held in the specified local store
    ///
    /// The new instance will contain the user information held in the local
    /// store if it exists there. If it does not, then a new user is returned
    /// with the local store
    /// - Parameter localStore: an in-memory or disk based store which defaults
    /// to UserDefaults if not provided by the caller
    public init(localStore: LocalStorageProtocol = UserDefaults.standard) {
        guard let data = localStore.value(key: LocalStore.Key.user) as? Data else {
            // in legacy versions, the user uuid was held in the local store
            // under the LocalStore.Key.userUuid key, while other user details
            // were held in CoreData
            uuid = localStore.value(key: LocalStore.Key.userUuid) as! F4SUUID?
            firstName = ""
            email = ""
            self.localStore = localStore
            return
        }
        let storedUser = try! JSONDecoder().decode(F4SUser.self, from: data)
        self.updateFrom(storedUser)
        self.localStore = localStore
    }
    
    /// Create a new F4SUserInformation value type from this instance
    public func extractUserInformation() -> F4SUserInformation {
        return F4SUserInformation(
            uuid: self.uuid,
            consenterEmail: self.consenterEmail,
            parentEmail: self.parentEmail,
            dateOfBirth: self.dateOfBirth,
            email: self.email,
            firstName: self.firstName,
            lastName: self.lastName,
            requiresConsent: self.requiresConsent,
            termsAgreed: self.termsAgreed,
            vouchers: self.vouchers,
            partners: self.partners,
            isOnboarded: self.isOnboarded,
            isRegistered: self.isRegistered)
    }
    
    /// Update this instance with information held in the specified object
    ///
    /// - Parameter info: an object holding the user information
    public func updateFrom(_ user: F4SUserProtocol) {
        self.uuid = user.uuid
        self.dateOfBirth = user.dateOfBirth
        self.consenterEmail = user.consenterEmail
        self.parentEmail = user.parentEmail
        self.email = user.email
        self.firstName = user.firstName
        self.lastName = user.lastName
        self.termsAgreed = user.termsAgreed
        self.requiresConsent = user.requiresConsent
        self.vouchers = user.vouchers
        self.partners = user.partners
    }
    
    /// Initialises a new instance from a CoreData record
    ///
    /// This is almost obsolete now. It is required only for backward compatability
    /// with old versions of the app that stored all user data in CoreData rather than
    /// a LocalStore
    /// - Parameter userData: a CoreData user record
    public init(userData: UserData, localStore: LocalStorageProtocol = LocalStore()) {
        uuid = (localStore.value(key: LocalStore.Key.userUuid) as? F4SUUID) ?? userData.userUuid
        if let partnerUuid = localStore.value(key: LocalStore.Key.partnerID) as? F4SUUID {
            self.partners = [F4SUUIDDictionary(uuid: partnerUuid)]
        }
        email = userData.email ?? ""
        firstName = userData.firstName ?? ""
        lastName = userData.lastName?.isEmpty == false ? userData.lastName : nil
        consenterEmail = userData.consenterEmail
        parentEmail = userData.consenterEmail
        requiresConsent = userData.requiresConsent
        if let dateOfBirth = userData.dateOfBirth {
            self.dateOfBirth =  Date.dateFromRfc3339(string: dateOfBirth)
        }
    }
}

extension F4SUser {
    private enum CodingKeys : String, CodingKey {
        case uuid
        case firstName = "first_name"
        case lastName = "last_name"
        case email
        case dateOfBirth = "date_of_birth"
        case requiresConsent = "requires_consent"
        case consenterEmail = "consenter_email"
        case parentEmail = "parent_email"
        case placementUuid = "placement_uuid"
        case termsAgreed = "terms_agreed"
        case vouchers
        case partners
    }
}
