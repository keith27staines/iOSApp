
public struct Recommendation: Codable, Hashable {
    public var uuid: F4SUUID?
    public var user: F4SUUID?
    public var association: F4SUUID?
    public var project: ProjectJson?
    public var createdAt: String?
    public var sentAt: String?
    public var confidence: Double?
    
    public init() {}
    
    enum CodingKeys: String, CodingKey {
        case uuid
        case user
        case association
        case project
        case createdAt = "created_at"
        case sentAt = "sent_at"
        case confidence
    }
}
