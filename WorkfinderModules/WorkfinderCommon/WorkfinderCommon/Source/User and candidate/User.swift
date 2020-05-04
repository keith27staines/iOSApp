
public struct User: Codable {
    public var uuid: F4SUUID?
    public var candidateUuid: F4SUUID?
    public var fullname: String?
    public var nickname: String?
    public var email: String?
    public var password: String?
    
    public init() {}
    
    private enum CodingKeys : String, CodingKey {
        case uuid
        case candidateUuid = "candidate"
        case fullname = "full_name"
        case nickname
        case email
        case password
    }
}

public struct UserRegistrationToken: Codable {
    public let key: String
}
