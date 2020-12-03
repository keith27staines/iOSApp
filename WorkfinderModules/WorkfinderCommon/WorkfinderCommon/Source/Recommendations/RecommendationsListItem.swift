
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
        public var name: String?
        public var description: String?
        public var isPaid: Bool?
        public var status: String?
        public var isRemote: Bool?
        public var duration: String?
        public var type: F4SUUID?
        public var additionalComments: String?
        public var association: ExpandedAssociation?
        public var employmentType: String?
        
        enum CodingKeys: String, CodingKey {
            case uuid
            case name
            case description
            case isPaid = "is_paid"
            case isRemote = "is_remote"
            case status
            case duration
            case type
            case additionalComments = "additional_comments"
            case association
            case employmentType = "employment_type"
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
        public var photo: String?
        public var fullName: String?
        enum CodingKeys: String, CodingKey {
            case uuid
            case photo
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

