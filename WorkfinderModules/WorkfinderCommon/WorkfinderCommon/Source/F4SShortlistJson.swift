import Foundation


public struct F4SServerErrors : Codable {
    public var errors: F4SJSONValue
}

public struct F4SShortlistJson : Codable {
    public var uuid: F4SUUID?
    public var companyUuid: F4SUUID?
    public var errors: F4SServerErrors?
    
    enum CodingKeys : String, CodingKey {
        case uuid
        case companyUuid = "company_uuid"
        case errors
    }
    
    public init(uuid: F4SUUID?, companyUuid: F4SUUID?, errors: F4SServerErrors? = nil) {
        self.uuid = uuid
        self.companyUuid = companyUuid
        self.errors = errors
    }
}
