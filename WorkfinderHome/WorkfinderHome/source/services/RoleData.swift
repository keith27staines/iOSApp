
import WorkfinderCommon

struct RoleData: Codable {
    var id: String?
    var recommendationUuid: String?
    var roleLogoUrlString: String?
    var projectTitle: String?
    var companyName: String?
    var companyLogoUrlString: String?
    var paidHeader: String?
    var paidAmount: String?
    var workingHours: String?
    var locationHeader: String?
    var location: String?
    var actionButtonText: String?
}

extension RoleData {
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
