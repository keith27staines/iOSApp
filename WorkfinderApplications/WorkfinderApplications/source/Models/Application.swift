import Foundation
import WorkfinderCommon

struct Application : Codable {
    var placementUuid: String
    var companyUuid: String?
    var hostUuid: String?
    var associationUuid: String?
    var state: ApplicationState
    var hostName: String
    var hostRole: String
    var roleName: String = ""
    var companyName: String
    var industry: String?
    var logoUrl: String?
    var appliedDate: String
    var coverLetterString: String
    var projectName: String
    
    init(
        placementUuid: F4SUUID,
        companyUuid: String,
        hostUuid: String,
        associationUuid: String,
        state: ApplicationState,
        hostName: String,
        hostRole: String,
        companyName: String,
        industry: String,
        logoUrl: String,
        appliedDate: String,
        coverLetterString: String,
        projectName: String
    ) {
        self.placementUuid = placementUuid
        self.companyUuid = companyUuid
        self.hostUuid = hostUuid
        self.associationUuid = associationUuid
        self.state = state
        self.hostName = hostName
        self.hostRole = hostRole
        self.companyName = companyName
        self.industry = industry
        self.logoUrl = logoUrl
        self.appliedDate = appliedDate
        self.coverLetterString = coverLetterString
        self.projectName = projectName
    }

    init(json: ApplicationJson) {
        self.placementUuid = json.uuid ?? "unknown uuid"
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
