
public struct ProjectTypeJson: Codable, Equatable {
    public var uuid: String?
    public var name: String?
    public var description: String?
    public var readMoreUrl: String?
    public var icon: String?
    public var activities: [UUIDAndNameJson]?
    public var skillsAcquired: [String]?
    public var aboutCandidate: String?

    enum CodingKeys: String, CodingKey {
        case uuid
        case name
        case description
        case readMoreUrl = "read_more_url"
        case icon
        case activities
        case skillsAcquired = "skills_acquired"
        case aboutCandidate = "about_candidate"
    }
}

public struct UUIDAndNameJson: Codable, Equatable {
    public var uuid: String?
    public var name: String?
}
