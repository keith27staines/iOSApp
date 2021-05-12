
public struct DeeplinkRoutingInfo {
    public let url: URL?
    public let queryItems: [String: String]
    public let source: Source
    public let objectType: ObjectType
    public let objectId: F4SUUID?
    public var action: Action { objectId == nil ? .list : .open }
    
    public enum Source: String {
        case deeplink
        case pushNotification
    }
    
    public enum ObjectType: String {
        case recommendation
        case placement
        case review
        case projects
        
        public init?(urlPathComponent: String?) {
            switch urlPathComponent {
            case "recommendation", "recommendations":
                self = .recommendation
            case "placement", "placements":
                self = .placement
            case "reviews":
                self = .review
            case "projects":
                self = .projects
            default:
                return nil
            }
        }
    }
    
    public enum Action: String {
        case list
        case open
    }
    
    public init(
        source: Source,
        objectType: ObjectType,
        objectId: F4SUUID?,
        queryItems: [String:String]) {
        self.source = source
        self.objectType = objectType
        self.objectId = objectId
        self.queryItems = queryItems
        self.url = nil
    }
    
    public init?(pushNotification: PushNotification?) {
        guard
            let pushNotification = pushNotification,
            let objectType = ObjectType(rawValue: pushNotification.objectType ?? "")
        else { return nil}
        
        self.init(
            source: Source.pushNotification,
            objectType: objectType,
            objectId: pushNotification.objectId,
            queryItems: [:]
        )
    }
    
    public init?(deeplinkUrl: URL) {
        self.source = .deeplink
        self.url = deeplinkUrl
        guard let components = URLComponents(url: deeplinkUrl, resolvingAgainstBaseURL: false) else {
            return nil
        }
        let pathComponents = components.path.split(separator: "/")
        switch components.scheme {
        case "workfinderapp":
            guard
                let host = components.host,
                let objectType = ObjectType(urlPathComponent: host)
            else { return nil }
            self.objectType = objectType
            if let firstPathComponent = pathComponents.first {
                self.objectId = String(firstPathComponent)
            } else {
                self.objectId = nil
            }
        default:
            guard
                let host = components.host,
                host.contains("workfinder.com"),
                let firstPathComponent = pathComponents.first,
                let objectType = ObjectType(urlPathComponent: String(firstPathComponent))
            else { return nil }
            self.objectType = objectType
            if pathComponents.count == 2 {
                self.objectId = String(pathComponents[1])
            } else {
                self.objectId = nil
            }
        }
        
        var parameters = [String:String]()
        components.queryItems?.forEach {
            parameters[$0.name] = $0.value
        }
        self.queryItems = parameters
    }
}
