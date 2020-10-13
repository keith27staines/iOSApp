
public struct PushNotification {
    public var text: String?
    public var objectType: String?
    public var objectId:  F4SUUID?
    public var action: String?
    
    public init?(userInfo: [AnyHashable:Any]) {
        guard let _ = userInfo["aps"] as? [AnyHashable: Any] else { return nil }
        objectType = userInfo["object_type"] as? String
        objectId = userInfo["object_id"] as? String
        action = userInfo["action"] as? String
    }
}
