import Foundation

public struct F4STimelinePlacement : Codable {
    public var placementUuid: F4SUUID?
    public var userUuid: F4SUUID?
    public var companyUuid: F4SUUID?
    public var threadUuid: F4SUUID?
    public var workflowState: WEXPlacementState?
    public var latestMessage: F4SMessage?
    public var roleUuid: F4SUUID?
    public var availabilityPeriods: [F4SAvailabilityPeriodJson]?
    public var voucher: String?
    public var totalHours: Double?
    public var duration: F4SAvailabilityPeriodJson?
    public var personResponsible: F4SPersonJson?
    public var location: F4SLocationJson?
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
    
    public var readDate: Date? {
        return nil
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
    var readDate: Date? { get }
    var isRead: Bool? { get }
    var text: String? { get }
}

public extension MessageProtocol {
    
    func isEqual(other: MessageProtocol) -> Bool {
        if uuid == other.uuid { return true }
        return self.dateToOrderBy == other.dateToOrderBy && self.senderId == other.senderId
    }
    
    var isRead: Bool? { return readDate != nil }
    
    var dateToOrderBy: Date {
        return sentDate ?? receivedDate ?? Date.distantFuture
    }
}
