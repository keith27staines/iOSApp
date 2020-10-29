
public struct PlacementOtherableFact: Codable {
    public let uuid: F4SUUID?
    public let other: String?
    
    public init?(item: PicklistItemJson?) {
        guard let item = item else { return nil }
        if item.isOther {
            self.init(other: item.otherValue)
        } else {
            self.init(uuid: item.uuid)
        }
    }
    
    init?(uuid: F4SUUID?) {
        guard let uuid = uuid else { return nil }
        self.uuid = uuid
        self.other = nil
    }
    init?(other: String?) {
        guard let other = other else { return nil }
        self.other = other
        self.uuid = nil
    }
}

public struct PlacementAvailability: Codable {
    public var lower: String?
    public var upper: String?
    public init(lower: String?, upper: String?) {
        self.lower = lower
        self.upper = upper
    }
}

public struct Placement: Codable {
    public var uuid: F4SUUID?
    public var candidateUuid: F4SUUID?
    public var associationUuid: F4SUUID?
    public var coverLetterString: F4SUUID?
    public var createdDatetimeString: String?
    public var status: String?
    
    public var yearOfStudy: PlacementOtherableFact?
    public var subject: PlacementOtherableFact?
    public var project: PlacementOtherableFact?
    public var associatedProject: F4SUUID?
    
    public var institution: F4SUUID?
    public var placementType: F4SUUID?
    public var motivation: String?
    public var experience: String?
    public var availability: PlacementAvailability?
    public var startDate: String?
    public var endDate: String?
    public var duration: F4SUUID?
    public var personalAttributes: [F4SUUID]?
    public var skills: [F4SUUID?]?
    public var strongestSkills: [F4SUUID]?
    
    public init() {
    }
    
    private enum CodingKeys: String, CodingKey {
        case uuid
        case candidateUuid = "candidate"
        case associationUuid = "association"
        case coverLetterString = "cover_letter"
        case createdDatetimeString = "created_at"
        case status
        
        case yearOfStudy = "year_of_study"
        case subject
        case institution
        case placementType = "placement_type"
        case project
        case associatedProject = "associated_project"
        case motivation
        case experience
        case availability
        case startDate = "start_date"
        case endDate = "end_date"
        case duration
        case personalAttributes = "attributes"
        case skills = "employment_skills"
        case strongestSkills = "strongest_skills"
    }
}
