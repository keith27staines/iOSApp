import Foundation

public struct PinJson: Codable, Hashable {
    public var workplaceUuid: String
    public var lat: Double
    public var lon: Double
    public var tags: [F4SUUID]
}

public class CompanyWorkplace: Codable {
    public var companyJson: F4SCompanyJson
    public var pinJson: PinJson
    public init(companyJson: F4SCompanyJson, pinJson: PinJson) {
        self.companyJson = companyJson
        self.pinJson = pinJson
    }
}

public struct F4SCompanyJson : Codable {
    public var uuid: F4SUUID
    public var name: String
    public var industry: String?
    public var logoUrlString: String?
    public var summary: String?
    public var employeeCount: Int?
    public var turnover: Double?
    public var turnoverGrowth: Double?
    public var duedilUrlString: String?
    public var linkedInUrlString: String?
    
    public init() {
        uuid = ""
        name = ""
    }
    
    public init(
        uuid: F4SUUID,
        name: String,
        industry: String?,
        logoUrlString: String?,
        summary: String?,
        employeeCount: Int?,
        turnover: Double?,
        turnoverGrowth: Double?,
        duedilUrlString: String?,
        linkedInUrlString: String?) {
        self.uuid = uuid
        self.name = name
        self.industry = industry
        self.logoUrlString = logoUrlString
        self.summary = summary
        self.employeeCount = employeeCount
        self.turnover = turnover
        self.turnoverGrowth = turnoverGrowth
        self.duedilUrlString = duedilUrlString
        self.linkedInUrlString = linkedInUrlString
    }
}

extension F4SCompanyJson {
    private enum CodingKeys : String, CodingKey {
        case uuid
        case name
        case industry
        case logoUrlString = "logo_url"
        case employeeCount = "employee_count"
        case turnover
        case turnoverGrowth = "turnover_growth"
        case summary
        case linkedInUrlString = "linkedin_url"
        case duedilUrlString = "duedil_url"
    }
}

public struct F4SHost : Codable {
    public var uuid: F4SUUID?
    public var displayName: String?
    public var firstName: String?
    public var lastName: String?
    public var profileUrl: String?
    public var imageUrl: String?
    public var gender: String?
    public var isInterestedInHosting: Bool?
    public var isCurrentEmployee: Bool?
    public var role: String?
    public var summary: String?
    public var isSelected: Bool = false
    
    public init(
        uuid: F4SUUID,
        displayName: String? = nil,
        firstName: String? = nil,
        lastName: String? =  nil,
        profileUrl: String? = nil,
        imageUrl: String? = nil,
        gender: String? = nil,
        isInterestedInHosting: Bool? = nil,
        isCurrentEmployee: Bool? = nil,
        role: String? = nil,
        summary: String? = nil) {
        
        self.uuid = uuid
        self.displayName = displayName
        self.firstName = firstName
        self.lastName = lastName
        self.profileUrl = profileUrl
        self.imageUrl = imageUrl
        self.gender = gender
        self.isInterestedInHosting = isInterestedInHosting
        self.isCurrentEmployee = isCurrentEmployee
        self.role = role
        self.summary = summary
    }
}

extension F4SHost {
    private enum CodingKeys : String, CodingKey {
        case uuid = "f4s_id"
        case displayName = "formatted_name"
        case firstName = "first_name"
        case lastName = "last_name"
        case profileUrl = "profile_url"
        case imageUrl = "picture_url"
        case gender
        case isInterestedInHosting = "is_interested_in_working"
        case isCurrentEmployee = "is_current"
        case role = "job_title"
        case summary
    }
}

