import Foundation

/// Defines the workflow states of a WEXPlacement
public enum WEXPlacementState : String, Codable {
    case inProgress = "in_progress"
    case applied
    case accepted
    case rejected
    case confirmed
    case declined
    case completed
    case draft
    case noAge =  "no_age"
    case noVoucher = "no_voucher"
    case noParentalConsent = "no_parental_consent"
    case unsuccessful
    case moreInfoRequested = "more info requested"
    case referredByEmployer = "referred by employer"
}

/// Defines the interface for 
public protocol F4SCreatePlacementJsonProtocol : Codable {
    var userUuid: F4SUUID { get }
    var companyUuid: F4SUUID { get }
    var vendorUuid: F4SUUID { get }
    var interests: [F4SUUID] { get }
}

public struct F4SCreatePlacementJson : F4SCreatePlacementJsonProtocol, Codable {
    public init(user: F4SUUID, roleUuid: F4SUUID, company: F4SUUID, vendor: F4SUUID, interests: [F4SUUID]) {
        self.userUuid = user
        self.roleUuid = roleUuid
        self.companyUuid = company
        self.vendorUuid = vendor
        self.interests = interests
    }
    public internal (set) var uuid: F4SUUID?
    public internal (set) var roleUuid: F4SUUID
    public internal (set) var userUuid: F4SUUID
    public internal (set) var companyUuid: F4SUUID
    public internal (set) var vendorUuid: F4SUUID
    public internal (set) var interests: [F4SUUID]
}

extension F4SCreatePlacementJson {
    private enum CodingKeys : String, CodingKey {
        case userUuid = "user_uuid"
        case roleUuid = "role_uuid"
        case companyUuid = "company_uuid"
        case vendorUuid = "vendor_uuid"
        case interests
    }
}

public struct F4SPlacementJson : Codable {
    public init(uuid: F4SUUID? = nil, user: F4SUUID? = nil, company: F4SUUID? = nil, vendor: F4SUUID? = nil, interests: [F4SUUID]? = nil) {
        self.uuid = uuid
        self.userUuid = user
        self.companyUuid = company
        self.vendorUuid = vendor
        self.interests = interests
    }
    public var uuid: F4SUUID?
    public var vendorUuid: F4SUUID?
    public var userUuid: F4SUUID?
    public var companyUuid: F4SUUID?
    public var interests: [F4SUUID]?
    public var skills: [F4SUUID]?
    public var attributes: [F4SUUID]?
    public var motivation: String?
    public var workflowState: WEXPlacementState?
    public var roleUuid: F4SUUID?
    public var availabilityPeriods: [F4SAvailabilityPeriodJson]?
    public var voucher: String?
    public var reviewed: Bool?
}


extension F4SPlacementJson {
    private enum CodingKeys : String, CodingKey {
        case uuid = "uuid"
        case vendorUuid = "vendor_uuid"
        case userUuid = "user_uuid"
        case companyUuid = "company_uuid"
        case interests
        case skills
        case attributes
        case motivation
        case workflowState = "workflow_state"
        case roleUuid = "role_uuid"
        case availabilityPeriods = "availability_periods"
        case voucher
        case reviewed
    }
}
