import WorkfinderCommon

struct Offer {
    var placementUuid: F4SUUID
    var offerState: OfferState?
    var startingDateString: String?
    var duration: String?
    var hostCompany: String?
    var hostContact: String?
    var email: String?
    var location: String?
    var logoUrl: String?
    var declineReason: DeclineReason?
}
