import Foundation

public struct User: Codable {
    public var fullname: String?
    public var nickname: String?
    public var email: String?
    public var password: String?
    
    public init() {}
    
    private enum CodingKeys : String, CodingKey {
        case fullname = "full_name"
        case nickname
        case email
        case password
    }
}

/// F4SUser represents the current user (assumed to be the only user)
public struct Candidate: Codable {
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
    
}

extension Candidate {
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
