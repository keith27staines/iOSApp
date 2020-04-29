
public struct Candidate: Codable {
    public var uuid: F4SUUID?
    public var dateOfBirth: String?
    public var employmentSkills: [F4SUUID]?
    public var motivation: String?
    public var experience: String?
    public var currentLevelOfStudy: String?
    public var placementType: String?
    public var fullName: String { self.userSummary.full_name }
    
    var userSummary: UserSummary
    
    public init() {
        self.userSummary = UserSummary()
    }
    
    private enum CodingKeys: String, CodingKey {
        case uuid
        case dateOfBirth = "date_of_birth"
        case userSummary = "user"
        case placementType = "placement_type"
        case currentLevelOfStudy = "current_level_of_study"
    }
    
    struct UserSummary: Codable {
        public var uuid: F4SUUID = ""
        public var full_name: String = ""
    }
}
