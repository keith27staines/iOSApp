
public struct DeeplinkRoutingInfo {
    
    public enum Source: String {
        case deeplink
        case pushNotification
    }
    
    public enum ObjectType: String {
        case recommendation
        case placement
        case review
        
        public init?(urlPathComponent: String?) {
            switch urlPathComponent {
            case "recommendation", "recommendations":
                self = .recommendation
            case "placement", "placements":
                self = .placement
            case "reviews":
                self = .review
            default:
                return nil
            }
        }
    }
    
    public enum Action: String {
        case list
        case open
    }
    
    public var queryItems: [String: String]
    public var source: Source
    public var objectType: ObjectType
    public var objectId: F4SUUID?
    public var action: Action
    
    public init(
        source: Source,
        objectType: ObjectType,
        objectId: F4SUUID?,
        action: Action,
        queryItems: [String:String]) {
        self.source = source
        self.objectType = objectType
        self.action = action
        self.objectId = objectId
        self.queryItems = queryItems
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
            action: action,
            queryItems: [:]
        )
    }
    
    public init?(deeplinkUrl: URL) {
        guard
            let (objectTypeString, objectId, queryItems) = DeeplinkRoutingInfo.deeplinkUrlToObjectAndId(url: deeplinkUrl),
            let objectType: ObjectType = ObjectType(urlPathComponent: objectTypeString)
        else { return nil }
        let action: Action = (objectId == nil) ? Action.list : Action.open
        var parameters = [String:String]()
        queryItems?.forEach {
            parameters[$0.name] = $0.value
        }
        self.init(
            source: Source.deeplink,
            objectType: objectType,
            objectId: objectId,
            action: action,
            queryItems: parameters
        )
    }
}

extension DeeplinkRoutingInfo {
    private static func deeplinkUrlToObjectAndId(url: URL) -> (String?, String?, [URLQueryItem]?)? {
        if let placementUuid = placementViewRequestUuid(url: url) {
            return ("placement", placementUuid, nil)
        }
        guard
            let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
            else { return nil }
        var object = urlComponents.path
        if object.first == "/" { object = String(object.dropFirst()) }
        if object.last == "/" { object = String(object.dropLast())  }
        return (urlComponents.host, object, urlComponents.queryItems)
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
