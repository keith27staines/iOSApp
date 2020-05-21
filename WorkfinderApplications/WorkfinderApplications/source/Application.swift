import Foundation
import WorkfinderCommon


struct Application : Codable {
    let placementUuid: String?
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
    
    public init(
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
}
