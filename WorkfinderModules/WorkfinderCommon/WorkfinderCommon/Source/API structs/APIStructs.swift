import Foundation

/// Standard server paged array `[TemplateModel]`
public typealias TemplateListJson = ServerListJson<TemplateModel>

/// Standard server paged array `[Host]`
public typealias HostListJson = ServerListJson<HostJson>

/// Standard server paged array `[PicklistItemJson]`
public typealias PicklistServerJson = ServerListJson<PicklistItemJson>

/// Standard server paged array `[CompanyJson]`
public typealias CompanyListJson = ServerListJson<CompanyJson>

/// Standard server paged array `[HostLocationAssociationJson]`
public typealias HostAssociationListJson = ServerListJson<HostAssociationJson>

// MARK: - Roles aka projects -

public struct RoleJson: Codable {
    public var uuid: F4SUUID?
    public var name: String?
    public var association: RoleNestedAssociation // ExpandedAssociation (because the api returns the country as a String, not a CodeName
    public var is_remote: Bool?
    public var is_paid: Bool?
    public var employment_type: String?
}

// MARK: - Company -

/// Represents JSON returned from the companies/uuid api
public struct CompanyJson: Codable, Equatable, Hashable {
    public var uuid: String?
    public var name: String?
    public var description: String?
    public var industries: [CodeAndName]?
    public var logo: String?
    public var duedilUrlString: String?
    public var locations: [CompanyNestedLocationJson]?
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
        locations: [CompanyNestedLocationJson]?,
        linkedInUrlString: String? = nil,
        status: String? = nil) {
        self.uuid = uuid
        self.name = name
        self.industries = industries
        self.logo = logoUrlString
        self.description = description
        self.employeeCount = employeeCount
        self.turnover = turnover
        self.growth = growth
        self.duedilUrlString = duedilUrlString
        self.locations = locations
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

// MARK: - Location -

/// Represents JSON returned from the locations/uuid api
public struct LocationJson: Codable, Equatable, Hashable {
    public var uuid: String?
    public var company: CompanyJson?
    public var addressUnit: String?
    public var addressBuilding: String?
    public var addressStreet: String?
    public var addressCity: String?
    public var addressRegion: String?
    public var addressCountry: CodeAndName?
    public var addressPostcode: String?
    public var geometry: PointJson?
    
    private enum CodingKeys: String, CodingKey {
        case uuid
        case company
        case addressUnit        = "address_unit"
        case addressBuilding    = "address_building"
        case addressStreet      = "address_street"
        case addressCity        = "address_city"
        case addressRegion      = "address_region"
        case addressCountry     = "address_country"
        case addressPostcode    = "address_postcode"
        case geometry
    }
    
    public init(postcode: String?) {
        self.addressPostcode = postcode
    }
}

/// Similar to a location but the company field is a uuid rather than a CompanyJson.
public struct CompanyNestedLocationJson: Codable, Equatable, Hashable {
    public var uuid: String?
    public var companyUuid: F4SUUID?
    public var addressUnit: String?
    public var addressBuilding: String?
    public var addressStreet: String?
    public var addressCity: String?
    public var addressRegion: String?
    public var addressCountry: CodeAndName?
    public var addressPostcode: String?
    public var geometry: PointJson?
    
    private enum CodingKeys: String, CodingKey {
        case uuid
        case companyUuid        = "company"
        case addressUnit        = "address_unit"
        case addressBuilding    = "address_building"
        case addressStreet      = "address_street"
        case addressCity        = "address_city"
        case addressRegion      = "address_region"
        case addressCountry     = "address_country"
        case addressPostcode    = "address_postcode"
        case geometry
    }
    
    public init(postcode: String?) {
        self.addressPostcode = postcode
    }
}

/// A nested JSON struct returned by RolesService. Differs from LocationJson only in that the address country is a string rather than a CodeName
public struct RoleNestedAssociationLocation: Codable, Equatable, Hashable {
    public var uuid: String?
    public var company: CompanyJson?
    public var addressUnit: String?
    public var addressBuilding: String?
    public var addressStreet: String?
    public var addressCity: String?
    public var addressRegion: String?
    public var addressCountry: String?
    public var addressPostcode: String?
    public var geometry: PointJson?
    
    private enum CodingKeys: String, CodingKey {
        case uuid
        case company            = "company"
        case addressUnit        = "address_unit"
        case addressBuilding    = "address_building"
        case addressStreet      = "address_street"
        case addressCity        = "address_city"
        case addressRegion      = "address_region"
        case addressCountry     = "address_country"
        case addressPostcode    = "address_postcode"
        case geometry
    }
    
    public init(postcode: String?) {
        self.addressPostcode = postcode
    }
}

// MARK: - Host -

public struct HostJson : Codable, Equatable, Hashable {
    
    public var uuid: F4SUUID?
    public var fullName: String?
    public var linkedinUrlString: String?
    public var photoUrlString: String?
    public var description: String?
    public var emails: [String]?
    
    public init(
        uuid: F4SUUID,
        displayName: String? = nil,
        linkedinUrlString: String? = nil,
        photoUrlString: String? = nil,
        role: String? = nil,
        summary: String? = nil) {
        
        self.uuid = uuid
        self.fullName = displayName
        self.linkedinUrlString = linkedinUrlString
        self.photoUrlString = photoUrlString
        self.description = summary
    }

    private enum CodingKeys : String, CodingKey {
        case uuid
        case fullName = "full_name"
        case linkedinUrlString = "linkedin_url"
        case photoUrlString = "photo"
        case description
        case emails
    } 
}

// MARK: - Association -

public struct ExpandedAssociation: Codable, Equatable, Hashable {
    public var uuid: F4SUUID?
    public var location: LocationJson?
    public var host: HostJson?
    public var title: String?
    public var description: String?
    public var started: String?
    public var stopped: String?
    public var isSelected: Bool = false
    private enum CodingKeys: String, CodingKey {
        case uuid
        case location
        case host
        case title
        case description
        case started
        case stopped
    }
    
    public init() {}
}

/// Like an AssociationJson but with a full host object rather than a uuid
public struct HostAssociationJson: Codable {
    public var uuid: F4SUUID?
    public var locationUuid: F4SUUID?
    public var host: HostJson?
    public var title: String?
    public var description: String?
    public var started: String?
    public var stopped: String?
    public var isSelected: Bool = false
    
    public init(uuidAssociation: AssociationJson, host:HostJson) {
        self.uuid = uuidAssociation.uuid
        self.locationUuid = uuidAssociation.locationUuid
        self.host = host
        self.title = uuidAssociation.title
        self.description = uuidAssociation.description
        self.started = uuidAssociation.started
        self.stopped = uuidAssociation.stopped
        self.isSelected = uuidAssociation.isSelected
    }
    
    private enum CodingKeys: String, CodingKey {
        case uuid
        case locationUuid = "location"
        case host
        case title
        case description
        case started
        case stopped
    }
    
    public init() {}
}

/// Identical to ExpandedAssociation except for the type of the nested location object, as returned by projects/ and roles/ apis
public struct RoleNestedAssociation: Codable, Equatable, Hashable {
    public var uuid: F4SUUID?
    public var location: RoleNestedAssociationLocation?
    public var host: HostJson?
    public var title: String?
    public var description: String?
    public var started: String? = nil
    public var stopped: String? = nil
    private enum CodingKeys: String, CodingKey {
        case uuid
        case location
        case host
        case title
        case description
        case started
        case stopped
    }
}

public struct AssociationJson: Codable, Equatable, Hashable {
    public var uuid: F4SUUID
    public var locationUuid: F4SUUID
    public var hostUuid: F4SUUID
    public var title: String? = nil
    public var description: String? = nil
    public var started: String? = nil
    public var stopped: String? = nil
    public var isSelected: Bool = false
    
    public init(uuid: F4SUUID,locationUuid: F4SUUID, hostUuid: F4SUUID) {
        self.uuid = uuid
        self.locationUuid = locationUuid
        self.hostUuid = hostUuid
    }
    
    private enum CodingKeys: String, CodingKey {
        case uuid
        case locationUuid = "location"
        case hostUuid = "host"
        case title
        case description
        case started
        case stopped
    }
}

// MARK: - utility structs -
/// CodeAndName is a struct used to code or decode JSON dictionaries containing a name and code
public struct CodeAndName: Codable, Equatable, Hashable {
    public let code: String
    public let name: String
}

// MARK: - Workplace and pin -
/// locates a company on a map
public struct LocationPin: Codable, Hashable {
    public var locationUuid: String
    public var lat: Double
    public var lon: Double
    public var tags: [String]
    
    public init(locationUuid: F4SUUID, latitude: Double, longitude: Double) {
        self.locationUuid = locationUuid
        self.lat = latitude
        self.lon = longitude
        self.tags = []
    }
}

/// Represents a latitude/longitude with degrees
public struct PointJson : Codable, Equatable, Hashable {
    public var type: String?
    public var coordinates: [Float]
    public var latitude: CGFloat { return CGFloat(coordinates[1]) }
    public var longitude: CGFloat { return CGFloat(coordinates[0]) }
}

/// Represents a company and the pin data that positions the company on a map
public class CompanyAndPin: Codable {
    public var companyJson: CompanyJson
    public var locationPin: LocationPin
    public init(companyJson: CompanyJson, locationPin: LocationPin) {
        self.companyJson = companyJson
        self.locationPin = locationPin
    }
    public var postcode: String {
        companyJson.locations?.first?.addressPostcode ?? "unknown postcode"
    }
}
