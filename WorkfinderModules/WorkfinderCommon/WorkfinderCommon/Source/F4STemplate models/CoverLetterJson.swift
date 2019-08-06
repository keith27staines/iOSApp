import Foundation

public struct CoverLetterJson : Encodable {
    public init() {}
    public var placementUuid: F4SUUID?
    public var templateUuid: F4SUUID?
    public var userUuid: F4SUUID?
    public var companyUuid: F4SUUID?
    public var interests: [F4SUUID]?
    public var choices: [CoverLetterBlankJson]?
}

extension CoverLetterJson {
    private enum CodingKeys : String, CodingKey {
        case placementUuid = "uuid"
        case templateUuid = "coverletter_uuid"
        case userUuid = "user_uuid"
        case companyUuid = "company_uuid"
        case interests
        case choices = "coverletter_choices"
    }
}

public struct CoverLetterBlankJson : Encodable {
    public init() {}
    public var name: String?
    public var result: F4SJSONValue?
}
