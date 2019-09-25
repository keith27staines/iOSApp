import Foundation

public struct F4SCompanyJson : Codable {
    public var linkedInUrlString: String?
    public var duedilUrlString: String?
    public var linkedinUrl: URL? {
        return URL(string: self.linkedInUrlString ?? "")
    }
    public var duedilUrl: URL? {
        return URL(string: self.duedilUrlString ?? "")
    }
    public init() {
    }
}

extension F4SCompanyJson {
    private enum CodingKeys : String, CodingKey {
        case linkedInUrlString = "linkedin_url"
        case duedilUrlString = "duedil_url"
    }
}

public struct Company : Hashable {
    
    public static let defaultLogo = UIImage(named: "DefaultLogo")
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
        hasher.combine(latitude)
        hasher.combine(longitude)
    }
    
    public static func ==(lhs: Company, rhs: Company) -> Bool {
        if lhs.uuid == rhs.uuid && lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude {
            return true
        }
        return false
    }
    
    public var id: Int64
    public var created: Date
    public var modified: Date
    public var isAvailableForSearch: Bool
    public var uuid: String
    public var name: String {
        didSet { self.sortingName = name.stripCompanySuffix().lowercased() }
    }
    public var logoUrl: String
    public var industry: String
    public var latitude: Double
    public var longitude: Double
    public var summary: String
    public var employeeCount: Int64
    public var turnover: Double
    public var turnoverGrowth: Double
    public var rating: Double
    public var ratingCount: Double
    public var sourceId: String
    public var hashtag: String
    public var companyUrl: String
    public var interestIds: Set<Int64> = Set<Int64>()
    
    public init(id: Int64 = 0, created: Date = Date(), modified: Date = Date(), isAvailableForSearch: Bool = true, uuid: String = "", name: String = "", logoUrl: String = "", industry: String = "", latitude: Double = 0, longitude: Double = 0, summary: String = "", employeeCount: Int64 = 0, turnover: Double = 0, turnoverGrowth: Double = 0, rating: Double = 0, ratingCount: Double = 0, sourceId: String = "", hashtag: String = "", companyUrl: String = "") {
        self.id = id
        self.created = created
        self.modified = modified
        self.isAvailableForSearch = isAvailableForSearch
        self.uuid = uuid
        self.name = name
        self.logoUrl = logoUrl
        self.industry = industry
        self.latitude = latitude
        self.longitude = longitude
        self.summary = summary
        self.employeeCount = employeeCount
        self.turnover = turnover
        self.turnoverGrowth = turnoverGrowth
        self.rating = rating
        self.ratingCount = ratingCount
        self.sourceId = sourceId
        self.hashtag = hashtag
        self.companyUrl = companyUrl
        self.sortingName = name.stripCompanySuffix().lowercased()
    }
    
    /// The name after having been stripped of company suffixes (LTD, etc) and lowercased. Intended for use in searching scenarios, this is not a computed property.
    public var sortingName: String

}
