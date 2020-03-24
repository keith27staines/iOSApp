import Foundation

public struct PinJson: Codable, Hashable {
    public var workplaceUuid: String
    public var lat: Double
    public var lon: Double
    public var tags: [F4SUUID]
    
    public init(workplaceUuid: F4SUUID, latitude: Double, longitude: Double) {
        self.workplaceUuid = workplaceUuid
        self.lat = latitude
        self.lon = longitude
        self.tags = []
    }
}

public class CompanyWorkplace: Codable {
    public var companyJson: CompanyJson
    public var pinJson: PinJson
    public init(companyJson: CompanyJson, pinJson: PinJson) {
        self.companyJson = companyJson
        self.pinJson = pinJson
    }
}

public struct CompanyJson: Codable {
    public var uuid: String?
    public var name: String?
    public var description: String?
    public var industries: [String]?
    public var logoUrlString: String?
    public var duedilUrlString: String?
    public var locations: [CompanyLocationJson]
    public var employeeCount: Int?
    public var growth: Double?
    public var turnover: Double?
    public var turnoverGrowth: Double?
    public var linkedInUrlString: String?
    public var status: String?
    
    public init() {
        self.uuid = ""
        self.name = ""
        self.locations = []
    }
    
    public init(
        uuid: F4SUUID,
        name: String,
        industries: [String]? = nil,
        logoUrlString: String? = nil,
        description: String? = nil,
        employeeCount: Int? = nil,
        turnover: Double? = nil,
        turnoverGrowth: Double? = nil,
        duedilUrlString: String? = nil,
        locations: [CompanyLocationJson]?,
        linkedInUrlString: String? = nil,
        status: String? = nil) {
        self.uuid = uuid
        self.name = name
        self.industries = industries
        self.logoUrlString = logoUrlString
        self.description = description
        self.employeeCount = employeeCount
        self.turnover = turnover
        self.turnoverGrowth = turnoverGrowth
        self.duedilUrlString = duedilUrlString
        self.locations = locations ?? []
        self.linkedInUrlString = linkedInUrlString
        self.status = status
    }
    
    private enum codingKeys: String, CodingKey {
        case uuid
        case name
        case description
        case industries
        case logo
        case duedilUrlString = "duedil_url"
        case locations
        case employeeCount = "employee_count"
        case growth
        case turnover
        case turnoverGrowth = "turnover_growth"
        case linkedInUrlString = "linkedin_url"
        case status
    }
}

public struct CompanyLocationJson: Codable {
    public var uuid: String?
    public var postcode: String?
    public var point: PointJson?
    private enum codingKeys: String, CodingKey {
        case uuid
        case postcode = "address_postcode"
        case point
    }
    
    public init() {
    }
}

public struct PointJson : Codable {
    var type: String?
    var coordinates: [Float]
}

/* point
 {
    "type": "Point",
    "coordinates":[
        0.1442068,
        52.2338514
    ]
 }
*/


/* Structure returned from companies endpoint
{
  "uuid": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "name": "string",
  "names": [
    "string"
  ],
  "domains": [
    null
  ],
  "logo": "string",
  "description": "string",
  "industries": [
    null
  ],
  "emails": [
    "user@example.com"
  ],
  "phone_numbers": [
    null
  ],
  "twitter_handles": [
    "string"
  ],
  "instagram_handles": [
    "string"
  ],
  "duedil_url": "string",
  "footprint": "string",
  "locations": [
    {
      "uuid": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
      "address_unit": "string",
      "address_building": "string",
      "address_street": "string",
      "address_city": "string",
      "address_region": "string",
      "address_country": "string",
      "address_postcode": "string",
      "point": "string",
      "last_geocode_attempt": "2020-03-22T11:53:35.140Z"
    }
  ]
}
*/

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

