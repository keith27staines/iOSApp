import Foundation

/// Models a placement as used to populate threads and messages
public struct F4STimelinePlacement : Codable {
    /// The uuid of the placement
    public var placementUuid: F4SUUID?
    /// The uuid of the user
    public var userUuid: F4SUUID?
    /// The uuid of the company
    public var companyUuid: F4SUUID?
    /// The uuid of the message thread
    public var threadUuid: F4SUUID?
    /// The state of the application
    public var workflowState: F4SPlacementState?
    /// The last message on the thread associated with the placement
    public var latestMessage: F4SMessage?
    /// The uuid of the role being applied for
    public var roleUuid: F4SUUID?
    /// The availability period
    public var availabilityPeriods: [F4SAvailabilityPeriodJson]?
    /// The code of the voucher the user added to the placement
    public var voucher: String?
    /// The total hours of the placement
    public var totalHours: Double?
    /// The duration describes which days and hours are to be worked
    public var duration: F4SAvailabilityPeriodJson?
    /// The person responsible for the YP during the placement
    public var personResponsible: F4SPersonJson?
    /// The location where the work is to be performed
    public var location: F4SLocationJson?
    
    /// Initialises a new instance with the specified parameters
    ///
    /// - Parameters:
    ///   - userUuid: uuid of the user
    ///   - companyUuid: uuid of the company
    ///   - placementUuid: uuid of the placement
    public init(userUuid: F4SUUID, companyUuid: F4SUUID, placementUuid: F4SUUID) {
        self.userUuid = userUuid
        self.companyUuid = companyUuid
        self.placementUuid = placementUuid
    }
}

extension F4STimelinePlacement {
    private enum CodingKeys : String, CodingKey {
        case threadUuid = "thread_uuid"
        case placementUuid = "uuid"
        case userUuid = "user_uuid"
        case companyUuid = "company_uuid"
        case workflowState = "workflow_state"
        case latestMessage = "latest_message"
        case roleUuid = "role_uuid"
        case availabilityPeriods = "availability_periods"
        case voucher
        case totalHours = "total_hours"
        case duration
        case personResponsible = "person_responsible"
        case location
    }
}

extension F4STimelinePlacement : Equatable {
    public static func ==(lhs: F4STimelinePlacement, rhs: F4STimelinePlacement) -> Bool {
        return
            lhs.companyUuid == rhs.companyUuid &&
                lhs.latestMessage?.uuid == rhs.latestMessage?.uuid &&
                lhs.placementUuid ==  rhs.placementUuid &&
                lhs.workflowState == rhs.workflowState &&
                lhs.threadUuid == rhs.threadUuid &&
                lhs.userUuid == rhs.userUuid
    }
}

public struct F4SPersonJson : Codable {
    public var name: String?
    public var linkedinProfile: String?
    public var email: String?
}

extension F4SPersonJson {
    private enum CodingKeys : String, CodingKey {
        case name
        case linkedinProfile = "linkedin_profile"
        case email
    }
}

public struct F4SLocationJson : Codable {
    public var address: F4SAddressJson?
    public var phoneNumber: String?
    public var website: String?
    public var point: F4SPointJson?
}

extension F4SLocationJson {
    private enum CodingKeys : String, CodingKey {
        case address
        case phoneNumber = "phone_number"
        case website
        case point
    }
}

public struct F4SAddressJson : Codable {
    public var building: String?
    public var street: String?
    public var address3: String?
    public var town: String?
    public var locality: String?
    public var county: String?
    public var postcode: String?
}

public struct F4SPointJson : Codable {
    public var latitude: Double
    public var longitude: Double
}

extension F4SPointJson {
    private enum CodingKeys : String, CodingKey {
        case latitude = "lat"
        case longitude = "long"
    }
}

public struct F4SMessage : Codable {
    public var uuid: F4SUUID
    public var dateTime: Date?
    public var relativeDateTime: String?
    public var content: String
    public var sender: String?
    public var isRead: Bool?
    
    public init(uuid: String = "", dateTime: Date = Date(), relativeDateTime: String = "", content: String = "", sender: String = "") {
        self.uuid = uuid
        self.dateTime = dateTime
        self.relativeDateTime = relativeDateTime
        self.content = content
        self.sender = sender
    }
}

extension F4SMessage {
    private enum CodingKeys : String, CodingKey {
        case uuid
        case dateTime = "datetime"
        case relativeDateTime = "datetime_rel"
        case content
        case sender
        case isRead = "is_read"
    }
}

extension F4SMessage : MessageProtocol {
    
    public var senderId: String {
        return sender ?? "unknown sender"
    }
    
    public var sentDate: Date? {
        return dateTime
    }
    
    public var receivedDate: Date? {
        return dateTime
    }
    
    public var text: String? {
        return content
    }
}

public protocol MessageProtocol {
    var uuid: String { get }
    var senderId: String { get }
    var sentDate: Date? { get }
    var receivedDate: Date? { get }
    var isRead: Bool? { get }
    var text: String? { get }
}

public extension MessageProtocol {
    
    func isEqual(other: MessageProtocol) -> Bool {
        if uuid == other.uuid { return true }
        return self.dateToOrderBy == other.dateToOrderBy && self.senderId == other.senderId
    }
    
    var dateToOrderBy: Date {
        return sentDate ?? receivedDate ?? Date.distantFuture
    }
}
