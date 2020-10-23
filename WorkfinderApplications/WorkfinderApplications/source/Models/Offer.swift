import WorkfinderCommon

struct Offer {
    var placementUuid: F4SUUID
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
