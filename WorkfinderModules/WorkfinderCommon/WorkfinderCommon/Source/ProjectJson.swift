

public struct ProjectJson: Codable, Equatable, Hashable {
    public var uuid: F4SUUID?
    public var name: String?
    public var description: String?
    public var skillsAcquired: [String]?
    public var aboutCandidate: String?
    public var candidateActivities: [String]?
    public var type: String?
    public var association: RoleNestedAssociation?
    public var isPaid: Bool?
    public var status: String?
    public var candidateQuantity: String?
    public var additionalComments: String?
    public var isRemote: Bool?
    public var duration: String?
    public var startDate: String?
    public var hasApplied: Bool?
    public var dateApplied: String?
    public var salary: Double?
    public var employmentType: String?
    public var isCandidateLocationRequired: Bool? = true
    
    public init() {}
    
    enum CodingKeys: String, CodingKey {
        case uuid
        case name
        case description
        case skillsAcquired = "skills_acquired"
        case aboutCandidate = "about_candidate"
        case candidateActivities = "candidate_activities"
        case type
        case association
        case isPaid = "is_paid"
        case status
        case candidateQuantity = "candidate_quantity"
        case isRemote = "is_remote"
        case additionalComments = "additional_comments"
        case duration
        case startDate = "start_date"
        case hasApplied = "has_applied"
        case dateApplied = "date_applied"
        case employmentType = "employment_type"
        case salary
        case isCandidateLocationRequired = "is_candidate_location_required"
    }
}
