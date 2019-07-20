import Foundation

public protocol UserData {
    var userUuid: String? { get }
    var email: String? { get }
    var firstName: String? { get }
    var lastName: String? { get }
    var consenterEmail: String? { get }
    var requiresConsent: Bool { get }
    var dateOfBirth: String? { get }
}

public protocol F4SUserProtocol {
    var uuid: F4SUUID? { get }
    var email: String? { get set }
    var firstName: String? { get set }
    var lastName: String? { get set }
    var fullName: String? { get }
    var consenterEmail: String? { get set }
    var parentEmail: String? { get set }
    var requiresConsent: Bool { get set }
    var dateOfBirth: Date? { get set }
    var isRegistered: Bool { get }
    var isOnboarded: Bool { get }
    var vouchers: [F4SUUID]? { get set }
    var partners: [F4SUUIDDictionary]? { get set }
    var termsAgreed: Bool { get set }
    mutating func updateUuid(uuid: F4SUUID)
}
public extension F4SUserProtocol {
    var fullName: String? {
        let firstName = self.firstName ?? ""
        let lastName = self.lastName ?? ""
        var name = firstName
        if (!firstName.isEmpty && !lastName.isEmpty) { name = name + " "}
        name = name + lastName
        return name.isEmpty ? nil : name
    }
}

public struct F4SUUIDDictionary : Codable {
    public var uuid: F4SUUID
    public init(uuid: F4SUUID) {
        self.uuid = uuid
    }
}

public class F4SUser : F4SUserProtocol, Codable {
    
    public private (set) var uuid: F4SUUID?
    public var consenterEmail: String?
    public var parentEmail: String?
    public var dateOfBirth: Date?
    public var email: String?
    public var firstName: String?
    public var lastName: String?
    public var requiresConsent: Bool = false
    public var termsAgreed: Bool = false
    public var vouchers: [F4SUUID]?
    public var partners: [F4SUUIDDictionary]?
    
    public var placementUuid: F4SUUID?
    
    public func nullifyUuid() {
        uuid = nil
    }
    
    public var isOnboarded: Bool {
        guard let isFirstLaunch = localStore.value(key: LocalStore.Key.isFirstLaunch) as? Bool else { return false }
        return !isFirstLaunch
    }
    
    var localStore: LocalStorageProtocol = UserDefaults.standard
    var analytics: F4SAnalytics?
    
    public func didFinishOnboarding() {
        localStore.setValue(false, for: LocalStore.Key.isFirstLaunch)
    }
    
    public func age(on date: Date = Date()) -> Int? {
        guard let userBirthday = dateOfBirth else { return nil }
        let calendar = NSCalendar.current
        let ageComponents = calendar.dateComponents([.year], from: userBirthday, to: date)
        let age = ageComponents.year!
        return age
    }
    
    public init(userInformation user:F4SUserProtocol) {
        updateFrom(user)
    }
    
    public init(localStore: LocalStorageProtocol = UserDefaults.standard) {
        guard let data = localStore.value(key: LocalStore.Key.user) as? Data else {
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
    
    public func updateFromUserInformation(_ info: F4SUserInformation) {
        updateUuid(uuid: info.uuid!)
        self.dateOfBirth = info.dateOfBirth
        self.consenterEmail = info.consenterEmail
        self.parentEmail = info.parentEmail
        self.email = info.email
        self.firstName = info.firstName
        self.lastName = info.lastName
        self.termsAgreed = info.termsAgreed
        self.requiresConsent = info.requiresConsent
        self.vouchers = info.vouchers
        self.partners = info.partners
    }
    
    func updateFrom(_ user: F4SUserProtocol) {
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
    
    public init(userData: UserData) {
        let localStore = LocalStore()
        uuid = localStore.value(key: LocalStore.Key.userUuid) as! F4SUUID?
        if let partnerUuid = localStore.value(key: LocalStore.Key.partnerID) as? F4SUUID {
            self.partners = [F4SUUIDDictionary(uuid: partnerUuid)]
        }
        email = userData.email ?? ""
        firstName = userData.firstName ?? ""
        lastName = userData.lastName?.isEmpty == false ? userData.lastName : nil
        consenterEmail = userData.consenterEmail
        parentEmail = userData.consenterEmail
        if let dateOfBirth = userData.dateOfBirth {
            self.dateOfBirth =  Date.dateFromRfc3339(string: dateOfBirth)
        }
    }
    
    public var isRegistered: Bool { return uuid != nil }
    
    public func updateUuid(uuid: F4SUUID) {
        self.uuid = uuid
        analytics?.alias(userId: uuid)
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

public struct F4SUserInformation : F4SUserProtocol {
    public private (set) var uuid: F4SUUID?
    public var consenterEmail: String?
    public var parentEmail: String?
    public var dateOfBirth: Date?
    public var email: String?
    public var firstName: String?
    public var lastName: String?
    public var requiresConsent: Bool = false
    public var termsAgreed: Bool = false
    public var vouchers: [F4SUUID]?
    public var partners: [F4SUUIDDictionary]?
    public var isOnboarded: Bool
    public var isRegistered: Bool
    public mutating func updateUuid(uuid: F4SUUID) { self.uuid = uuid }
}
