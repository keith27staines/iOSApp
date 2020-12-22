
import WorkfinderCommon

public struct RoleData: Codable {
    public var id: String?
    public var recommendationUuid: String?
    public var roleLogoUrlString: String?
    public var projectTitle: String?
    public var companyName: String?
    public var companyLogoUrlString: String?
    public var paidHeader: String?
    public var paidAmount: String?
    public var workingHours: String?
    public var locationHeader: String?
    public var location: String?
    public var actionButtonText: String?
    public var applicationSource: ApplicationSource = .unspecified
    
    private enum CodingKeys: String, CodingKey {
        case id
        case recommendationUuid
        case roleLogoUrlString
        case projectTitle
        case companyName
        case companyLogoUrlString
        case paidHeader
        case paidAmount
        case workingHours
        case locationHeader
        case location
    }
    
    public func settingApplicationSource(_ source: ApplicationSource) -> RoleData {
        var role = self
        role.applicationSource = source
        return role
    }
}

public extension RoleData {
    init(recommendation: RecommendationsListItem) {
        let project = recommendation.project
        id = project?.uuid
        recommendationUuid = recommendation.uuid
        projectTitle = project?.name
        companyName = project?.association?.location?.company?.name
        companyLogoUrlString = project?.association?.location?.company?.logo
        paidHeader = "Paid (ph)"
        paidAmount = project?.isPaid == true ? "£6 - 8.21" : "Voluntary"
        locationHeader = "Location"
        location = project?.isRemote == false ?  "On site" : "Remote"
        workingHours = project?.employmentType 
        actionButtonText = "Discover more"
    }
}
