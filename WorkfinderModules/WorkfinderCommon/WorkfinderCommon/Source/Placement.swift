import Foundation

public enum PlacementStatus {
    case inProgress
    case applied
    case accepted
    case rejected
    case confirmed
    case completed
    case draft
    case noAge
    case noVoucher
    case noParentalConsent
    case unsuccessful
}

public struct Placement {
    public var companyUuid: String
    public var interestsList: [F4SInterest]
    public var status: PlacementStatus
    public var placementUuid: String
    
    public init(companyUuid: String = "", interestsList: [F4SInterest] = [], status: PlacementStatus = .inProgress, placementUuid: String = "") {
        self.companyUuid = companyUuid
        self.interestsList = interestsList
        self.status = status
        self.placementUuid = placementUuid
    }
}
