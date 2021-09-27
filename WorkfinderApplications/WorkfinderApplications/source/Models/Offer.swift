import WorkfinderCommon

struct Offer {
    var _placementJson: PlacementJson?
    var placementUuid: F4SUUID?
    var companyUuid: F4SUUID?
    var hostUuid: F4SUUID?
    var associationUuid: F4SUUID?
    var offerState: OfferState?
    var startDateString: String?
    var endDateString: String?
    var duration: Int?
    var hostCompany: String?
    var hostContact: String?
    var email: String?
    var location: String?
    var logoUrl: String?
    var reasonWithdrawn: WithdrawReason?
    var offerNotes: String?
    var isRemote: Bool?
    var salary: String?
}

extension Offer {
    init(json: PlacementJson) {
        self._placementJson = json
        placementUuid = json.uuid
        companyUuid = json.association?.location?.company?.uuid
        hostUuid = json.association?.host?.uuid
        associationUuid = json.association?.uuid
        let applicationState = ApplicationState(string: json.status)
        offerState = OfferState(applicationState: applicationState)
        startDateString = json.start_date
        endDateString = json.end_date
        duration = json.offered_duration
        hostCompany = json.association?.location?.company?.name
        hostContact = json.association?.host?.fullName
        email = json.association?.host?.emails?.first
        location = locationTextFromPlacement(from: json)
        logoUrl = json.association?.location?.company?.logo
        reasonWithdrawn = nil
        offerNotes = json.offer_notes
        isRemote = json.associated_project?.isRemote
        salary = json.salary
    }
    
    func locationTextFromPlacement(from json: PlacementJson) -> String {
        guard let isRemote = json.associated_project?.isRemote, isRemote == true else {
            return json.association?.location?.addressCity ?? ""
        }
        return "This is a remote project"
    }
}
