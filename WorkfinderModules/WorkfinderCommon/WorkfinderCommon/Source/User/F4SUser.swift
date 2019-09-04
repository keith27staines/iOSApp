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

/// F4SUser represents the current user (assumed to be the only user)
public struct F4SUser: Codable {
    public var uuid: F4SUUID?
    public var email: String? = ""
    public var firstName: String? = ""
    public var lastName: String?
    public var consenterEmail: String?
    public var parentEmail: String?
    public var requiresConsent: Bool = false
    public var dateOfBirth: Date?
    public var isRegistered: Bool { return uuid != nil }
    public var partners: [F4SUUIDDictionary]?
    public var termsAgreed: Bool = false
    
    public init(uuid: F4SUUID?,
                email: String? = "",
                firstName: String? = "",
                lastName: String? = nil,
                consenterEmail: String? = nil,
                parentEmail: String? = nil,
                requiresConsent: Bool = false,
                dateOfBirth: Date? = nil,
                partners: [F4SUUIDDictionary]? = nil,
                termsAgreed: Bool = false) {
        self.uuid = uuid
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.consenterEmail = consenterEmail
        self.parentEmail = parentEmail
        self.requiresConsent = requiresConsent
        self.dateOfBirth = dateOfBirth
        self.partners = partners
        self.termsAgreed = termsAgreed
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
    
    /// Initialises an instance from data held in the specified local store
    ///
    /// The new instance will contain the user information held in the local
    /// store if it exists there. If it does not, then a new user is returned
    /// with the local store
    /// - Parameter localStore: an in-memory or disk based store which defaults
    /// to UserDefaults if not provided by the caller
    public init() {
        firstName = ""
        email = ""
    }
    
    /// A careful implementation to derive the user's full name from their first
    /// and last name
    public var fullName: String? {
        let firstName = self.firstName ?? ""
        let lastName = self.lastName ?? ""
        var name = firstName
        if (!firstName.isEmpty && !lastName.isEmpty) { name = name + " "}
        name = name + lastName
        return name.isEmpty ? nil : name
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
        case termsAgreed = "terms_agreed"
        case partners
    }
}
