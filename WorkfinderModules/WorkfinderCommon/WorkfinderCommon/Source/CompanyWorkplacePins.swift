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
    public var postcode: String {
        let location = companyJson.locations.first { (location) -> Bool in
            location.uuid == self.pinJson.workplaceUuid
        }
        return location?.address_postcode ?? "unknown postcode"
    }
}

public struct CodeAndName: Codable {
    public let code: String
    public let name: String
}

public struct CompanyJson: Codable {
    public var uuid: String?
    public var name: String?
    public var description: String?
    public var industries: [CodeAndName]?
    public var logoUrlString: String?
    public var duedilUrlString: String?
    public var locations: [CompanyLocationJson]
    public var employeeCount: Int?
    public var growth: Double?
    public var turnover: Double?
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
        industries: [CodeAndName]? = nil,
        logoUrlString: String? = nil,
        description: String? = nil,
        employeeCount: Int? = nil,
        turnover: Double? = nil,
        growth: Double? = nil,
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
        self.growth = growth
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
        case linkedInUrlString = "linkedin_url"
        case status
    }
}

/* location json capture
 {
    "uuid":"bfbb0e1b-4f4d-4d43-95ea-6a6775fb92ae",
    "type":"registered",
    "address_unit":"",
    "address_building":"",
    "address_street":"",
    "address_city":"",
    "address_region":"",
    "address_country":"GB",
    "address_postcode":"W1D5LG",
    "point":{
        "type":"Point",
        "coordinates": [-0.13076,51.51275]
     },
    "last_geocode_attempt":null
 }
 */

public struct CompanyLocationJson: Codable {
    public var uuid: String?
    public var address_postcode: String?
    public var geometry: PointJson?
    private enum codingKeys: String, CodingKey {
        case uuid
        case address_postcode
        case point
    }
    
    public init() {
    }
}

public struct PointJson : Codable {
    public var type: String?
    public var coordinates: [Float]
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


/* Example host
 {
     "uuid": "389efb7e-daa9-413f-a3cb-c9dc5c520fef",
     "full_name": "Steven Gee",
     "names": [
         "Steven Gee"
     ],
     "emails": [],
     "user": null,
     "photo": "https://api-workfinder-com-develop.s3.amazonaws.com/develop/media/hosts/derived/389efb7e-daa9-413f-a3cb-c9dc5c520fef.jpg",
     "phone": "",
     "instagram_handle": "",
     "twitter_handle": "",
     "linkedin_url": "https://www.linkedin.com/in/steven-gee-8259681",
     "description": "",
     "associations": [
         "ebcc26fe-f9d6-455e-8dcf-35e97686f12d"
     ]
 }
 */
public struct Host : Codable {
    
    public var uuid: F4SUUID?
    public var displayName: String?
    public var linkedinUrlString: String?
    public var photoUrlString: String?
    public var description: String?
    public var isSelected: Bool = false
    
    public init(
        uuid: F4SUUID,
        displayName: String? = nil,
        linkedinUrlString: String? = nil,
        photoUrlString: String? = nil,
        role: String? = nil,
        summary: String? = nil) {
        
        self.uuid = uuid
        self.displayName = displayName
        self.linkedinUrlString = linkedinUrlString
        self.photoUrlString = photoUrlString
        self.description = summary
    }

    private enum CodingKeys : String, CodingKey {
        case uuid
        case displayName = "full_name"
        case linkedinUrlString = "linkedin_url"
        case photoUrlString = "photo"
        case description
    }
}

