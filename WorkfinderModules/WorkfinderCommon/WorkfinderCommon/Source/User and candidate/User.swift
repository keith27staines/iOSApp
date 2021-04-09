
/*
 {\"uuid\":\"249a185a-a62b-4c93-b4b3-7169bd01f131\",\"email\":\"keith.staines+c.develop@workfinder.com\",\"nickname\":\"Keith\",\"full_name\":\"Keith Staines\",\"url\":\"\",\"referral\":null,\"is_staff\":false,\"is_active\":true,\"last_login\":\"2021-04-09T17:21:03.868470Z\",\"created\":\"2020-10-12T13:04:03.519568Z\",\"modified\":\"2020-10-12T13:04:03.652462Z\",\"host\":null,\"candidate\":\"91756fe0-584d-4e47-8f83-68e978752a0c\",\"has_completed_profile\":true,\"preferred_notification_method\":\"apn\"}"
 */

public struct User: Codable {
    public var uuid: F4SUUID?
    public var candidateUuid: F4SUUID?
    public var fullname: String?
    public var nickname: String?
    public var email: String?
    public var password: String?
    public var lastLogin: String?
    public var created: String?
    public var preferredNotificationMethod: String?
    
    public init() {}
    
    private enum CodingKeys : String, CodingKey {
        case uuid
        case candidateUuid = "candidate"
        case fullname = "full_name"
        case nickname
        case email
        case password
        case lastLogin = "last_login"
        case created
        case preferredNotificationMethod = "preferred_notification_method"
    }
}

public struct UserRegistrationToken: Codable {
    public let key: String
}
