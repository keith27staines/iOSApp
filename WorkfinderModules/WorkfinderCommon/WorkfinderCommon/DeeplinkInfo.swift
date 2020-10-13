
public struct DeeplinkDispatchInfo {
    
    public enum Source: String {
        case deeplink
        case pushNotification
    }
    
    public enum ObjectType: String {
        case recommendation
        case placement
        public init?(urlPathComponent: String) {
            switch urlPathComponent {
            case "recommendation", "recommendations":
                self = .recommendation
            case "placement", "placements":
                self = .placement
            default:
                return nil
            }
        }
    }
    
    public enum Action: String {
        case list
        case open
    }
    
    public var source: Source
    public var objectType: ObjectType
    public var objectId: F4SUUID?
    public var action: Action
    
    public init(
        source: Source,
        objectType: ObjectType,
        objectId: F4SUUID?,
        action: Action) {
        self.source = source
        self.objectType = objectType
        self.action = action
        self.objectId = objectId
    }
    
    public init?(pushNotification: PushNotification?) {
        guard
            let pushNotification = pushNotification,
            let objectType = ObjectType(rawValue: pushNotification.objectType ?? ""),
            let action = Action(rawValue: pushNotification.action ?? "")
        else { return nil}
        self.init(
            source: Source.pushNotification,
            objectType: objectType,
            objectId: pushNotification.objectId,
            action: action)
    }
    
    public init?(deeplinkUrl: URL) {
        guard
            let (objectTypeString, objectId) = DeeplinkDispatchInfo.deeplinkUrlToObjectAndId(url: deeplinkUrl),
            let objectType: ObjectType = ObjectType(urlPathComponent: objectTypeString)
        else { return nil }
        let action: Action = (objectId == nil) ? Action.list : Action.open
        self.init(source: Source.deeplink, objectType: objectType, objectId: objectId, action: action)
    }
}

extension DeeplinkDispatchInfo {
    private static func deeplinkUrlToObjectAndId(url: URL) -> (String, String?)? {
        if let placementUuid = placementViewRequestUuid(url: url) {
            return ("placement", placementUuid)
        }
        guard
            let path = URLComponents(url: url, resolvingAgainstBaseURL: true)?.path.split(separator: "/")
            else { return nil }
        guard let firstPathComponent = path.first else { return nil }
        if path.count == 1 { return (String(firstPathComponent), nil) }
        let secondPathComponent = String(path[1])
        return (String(firstPathComponent), secondPathComponent)
    }
    
    private static func placementViewRequestUuid(url: URL) -> F4SUUID? {
        let prefix = "?placement="
        guard
            let path = url.absoluteString.removingPercentEncoding,
            let index: String.Index = path.index(of: prefix)
        else { return nil }
        let offset = path.index(index, offsetBy: prefix.count)
        let uuid = path[offset...]
        return String(uuid)
    }
}
