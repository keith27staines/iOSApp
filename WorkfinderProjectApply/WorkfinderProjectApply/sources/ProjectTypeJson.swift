
import WorkfinderCommon

struct ProjectTypeJson: Codable, Equatable {
    var uuid: String?
    var name: String?
    var readMoreUrl: String?
    var icon: String?
    var activities: [UUIDAndNameJson]?
    var skillsAcquired: [String]?
    var aboutCandidate: String?

    enum CodingKeys: String, CodingKey {
        case uuid
        case name
        case readMoreUrl = "read_more_url"
        case icon
        case activities
        case skillsAcquired = "skills_acquired"
        case aboutCandidate = "about_candidate"
    }
}

struct UUIDAndNameJson: Codable, Equatable {
    var uuid: String?
    var name: String?
}
