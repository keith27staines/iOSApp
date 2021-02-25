import Foundation
import WorkfinderCommon

struct Application : Codable {
    let placementUuid: String
    let companyUuid: String?
    let hostUuid: String?
    let associationUuid: String?
    let state: ApplicationState
    let hostName: String
    let hostRole: String
    let companyName: String
    let industry: String?
    let logoUrl: String?
    let appliedDate: String
    let coverLetterString: String
    
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
        coverLetterString: String) {
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
    }
}
