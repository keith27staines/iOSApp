

public struct RoleData: Codable, Hashable {
    public var id: String?
    public var recommendationUuid: String?
    public var roleLogoUrlString: String?
    public var projectTitle: String?
    public var companyName: String?
    public var companyLogoUrlString: String?
    public var paidHeader: String?
   
    public var workingHours: String?
    public var locationHeader: String?
    public var location: String?
    public var actionButtonText: String?
    public var appSource: AppSource = .unspecified
    public var isPaid: Bool?
    public var salary: Double?
    public var skillsAcquired = [String]()
    
    public var paidAmount: String {
        guard let isPaid = isPaid, isPaid == true else { return "Voluntary"}
        guard let salary = salary else { return "Paid" }
        return String(format: "£%.02f p/h", salary)
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case recommendationUuid
        case roleLogoUrlString
        case projectTitle
        case companyName
        case companyLogoUrlString
        case paidHeader
        case workingHours
        case locationHeader
        case location
        case skillsAcquired
    }
    
    public func settingAppSource(_ source: AppSource) -> RoleData {
        var role = self
        role.appSource = source
        return role
    }
    
    public init() {}
}

public extension RoleData {
    init(recommendation: RecommendationsListItem) {
        let project = recommendation.project
        id = project?.uuid
        projectTitle = project?.name
        companyName = project?.association?.location?.company?.name
        companyLogoUrlString = project?.association?.location?.company?.logo
        paidHeader = "Paid?"
        salary = project?.salary
        isPaid = project?.isPaid
        locationHeader = "Location"
        location = project?.isRemote == false ?  "On site" : "Remote"
        workingHours = project?.employmentType 
        actionButtonText = "Apply now"
        recommendationUuid = recommendation.uuid
        skillsAcquired = recommendation.project?.skillsAcquired ?? []
    }
    
    init(project: ProjectJson) {
        id = project.uuid
        projectTitle = project.type
        companyName = project.association?.location?.company?.name
        companyLogoUrlString = project.association?.location?.company?.logo
        paidHeader = "Paid?"
        salary = project.salary
        isPaid = project.isPaid
        locationHeader = "Location"
        location = project.isRemote == false ?  "On site" : "Remote"
        workingHours = project.employmentType
        actionButtonText = "Apply now"
        skillsAcquired = project.skillsAcquired ?? []
    }
}



