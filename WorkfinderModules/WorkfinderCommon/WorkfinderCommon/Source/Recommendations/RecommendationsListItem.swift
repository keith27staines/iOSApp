
public struct RecommendationsListItem: Codable, Hashable {
    public var uuid: F4SUUID?
    public var user: F4SUUID?
    public var association: ExpandedAssociation?
    public var createdAt: String?
    public var sentAt: String?
    public var confidence: Double?
    public var project: Project?
    
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
    
    public struct Project: Codable, Equatable, Hashable {
        public var uuid: F4SUUID?
        public var isPaid: Bool?
        public var isRemote: Bool?
        public var duration: String?
        public var type: ProjectType?
        public var association: ExpandedAssociation?
        
        enum CodingKeys: String, CodingKey {
            case uuid
            case isPaid = "is_paid"
            case isRemote = "is_remote"
            case duration
            case type
            case association
        }
        
        public struct ProjectType: Codable, Equatable, Hashable {
            public var uuid: F4SUUID?
            public var name: String?
        }
        
        public struct Activity: Codable, Equatable, Hashable {
            public var uuid: F4SUUID?
            public var name: String?
        }
        
    }
    
}

public struct ExpandedAssociation: Codable, Equatable, Hashable {
    public var uuid: F4SUUID?
    public var title: String?
    public var host: Host?
    public var location: Location?
    
    public struct Host: Codable, Equatable, Hashable {
        public var uuid: F4SUUID?
        public var photoUrl: String?
        public var fullName: String?
        enum CodingKeys: String, CodingKey {
            case uuid
            case fullName = "full_name"
        }
    }
    
    public struct Location: Codable, Equatable, Hashable {
        public var company: Company?
        public struct Company: Codable, Equatable, Hashable  {
            public var name: String?
            public var logo: String?
        }
    }
}

