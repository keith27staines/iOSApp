import Foundation
import WorkfinderCommon
import WorkfinderServices

struct Application : Codable {
    var _placementJson: PlacementJson
    var placementUuid: String
    var companyUuid: String?
    var hostUuid: String?
    var associationUuid: String?
    var state: ApplicationState
    var hostName: String
    var hostRole: String
    var roleName: String = ""
    var companyName: String
    var projectName: String
    var industry: String?
    var logoUrl: String?
    var appliedDate: String
    var coverLetterString: String
    var interviewJson: InterviewJson?
    
    init(json: PlacementJson) {
        self._placementJson = json
        self.placementUuid = json.uuid ?? ""
        self.companyUuid = json.association?.location?.company?.uuid
        self.hostUuid = json.association?.host?.uuid
        self.associationUuid = json.association?.uuid
        self.state = ApplicationState(string: json.status)
        self.hostName = json.association?.host?.fullName ?? "unknown name"
        self.hostRole = json.association?.title ?? "unknown role"
        self.companyName = json.association?.location?.company?.name ?? "unknown company"
        self.industry = json.association?.location?.company?.industries?.first?.name
        self.logoUrl = json.association?.location?.company?.logo
        self.appliedDate = json.created_at ?? "1700-01-01"
        self.coverLetterString = json.cover_letter ?? ""
        self.projectName = json.associated_project_name ?? ""
    }
}
