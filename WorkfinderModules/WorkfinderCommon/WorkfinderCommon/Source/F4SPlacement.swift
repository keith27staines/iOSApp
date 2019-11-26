import Foundation

/// Models a work experience placement application
public struct F4SPlacement : Codable {
    /// company at which the placement takes place
    public var companyUuid: F4SUUID?
    /// interests of the user
    public var interestList: [F4SInterest]
    /// status of the application
    public var status: F4SPlacementState?
    /// the unique id of the placement application
    public var placementUuid: F4SUUID?
    /// the unique uuid of the user
    public var userUuid: F4SUUID?
    
    
    /// Initialise a new instance with the parameters provided
    ///
    /// - Parameters:
    ///   - userUuid: the unique uuid of the user
    ///   - companyUuid: the unique uuid of the company being applied to
    ///   - interestList: a list of interests of the user
    ///   - status: the status of the application
    ///   - placementUuid: the unique uuid of the application
    public init(userUuid: F4SUUID? = nil, companyUuid: F4SUUID? = nil, interestList: [F4SInterest] = [], status: F4SPlacementState? = nil, placementUuid: F4SUUID? = nil) {
        self.userUuid = userUuid
        self.companyUuid = companyUuid
        self.interestList = interestList
        self.status = status
        self.placementUuid = placementUuid
    }
    
    
    /// Initialise a new instance from a timeline placement
    ///
    /// - Parameter timelinePlacement: the timeline placement
    public init(timelinePlacement: F4STimelinePlacement) {
        self.userUuid = timelinePlacement.userUuid
        self.companyUuid = timelinePlacement.companyUuid
        self.placementUuid = timelinePlacement.placementUuid
        self.status = timelinePlacement.workflowState
        self.interestList = []
    }
}

extension F4SPlacement {
    private enum CodingKeys : String, CodingKey {
        case userUuid = "user_uuid"
        case companyUuid = "company_uuid"
        case status
        case placementUuid = "placement_uuid"
        case interestList = "interests"
    }
}

/// Defines the workflow states of a placement application
public enum F4SPlacementState : String, Codable {
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
    public init(user: F4SUUID, roleUuid: F4SUUID, company: F4SUUID, hostUuid: F4SUUID?, vendor: F4SUUID, interests: [F4SUUID]) {
        self.userUuid = user
        self.roleUuid = roleUuid
        self.companyUuid = company
        self.hostUuid = hostUuid
        self.vendorUuid = vendor
        self.interests = interests
    }
    public internal (set) var uuid: F4SUUID?
    public internal (set) var roleUuid: F4SUUID
    public internal (set) var userUuid: F4SUUID
    public internal (set) var companyUuid: F4SUUID
    public internal (set) var hostUuid: F4SUUID?
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
        case hostUuid = "host_f4s_id"
    }
}

public struct F4SPlacementJson : Codable {
    public init(uuid: F4SUUID? = nil,
                user: F4SUUID? = nil,
                company: F4SUUID? = nil,
                vendor: F4SUUID? = nil,
                interests: [F4SUUID]? = nil,
                motivation: String? = nil) {
        self.uuid = uuid
        self.userUuid = user
        self.companyUuid = company
        self.vendorUuid = vendor
        self.interests = interests
        self.motivation = motivation
    }
    public var uuid: F4SUUID?
    public var vendorUuid: F4SUUID?
    public var userUuid: F4SUUID?
    public var companyUuid: F4SUUID?
    public var interests: [F4SUUID]?
    public var skills: [F4SUUID]?
    public var attributes: [F4SUUID]?
    public var motivation: String?
    public var workflowState: F4SPlacementState?
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
