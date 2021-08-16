
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
    
    static func unifyUniversalandDeeplinkUrls(url: URL) -> URL? {
        guard
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let host = components.host else {
            return nil
        }
        switch components.scheme {
        case "workfinderapp":
            var unifiedComponents = URLComponents()
            unifiedComponents.scheme = "https"
            unifiedComponents.host = "workfinder.com"
            unifiedComponents.path = "/" + (components.host ?? "unknown") + components.path
            unifiedComponents.queryItems = components.queryItems
            return unifiedComponents.url
        default:
            guard host.contains("workfinder.com") else { return nil }
            return url
        }
    }
    
    static func objectIdFromUnifiedURL(_ url: URL) -> F4SUUID? {
        let components = url.path.split(separator: "/").map { String($0) }
        guard
            let objectType = objectTypeFromUnifiedUrl(url),
            components.count > 1
        else {
            return nil
        }
    
        switch objectType {
        case .recommendation:
            return nil
        case .placement:
            return components[1]
        case .review:
            return components[1]
        case .projects:
            return components[1]
        case .interviewInvite:
            // iOS is not allowed to handle interview invites yet
            return nil // self = .interviewInvite
        case .studentDashboard:
            return nil
        }
    }
    
    static func objectTypeFromUnifiedUrl(_ url: URL) -> ObjectType? {
        let components = url.path.split(separator: "/")
        guard let firstComponent = components.first else { return nil }
        switch firstComponent {
        case "recommendation", "recommendations":
            return .recommendation
        case "placement", "placements":
            return .placement
        case "reviews":
            return .review
        case "projects":
            return .projects
        case "interviews":
            // iOS is not allowed to handle interview invites yet
            return nil // self = .interviewInvite
        case "students":
            return .studentDashboard
        default:
            return nil
        }

    }
    
    public enum ObjectType: String {
        case recommendation
        case placement
        case review
        case projects
        case interviewInvite
        case studentDashboard
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
        guard
            let unifiedUrl = Self.unifyUniversalandDeeplinkUrls(url: deeplinkUrl),
            let components = URLComponents(url: unifiedUrl, resolvingAgainstBaseURL: false),
            let objectType = Self.objectTypeFromUnifiedUrl(unifiedUrl)
        else { return nil }
        self.objectType = objectType
        self.source = .deeplink
        self.url = deeplinkUrl
        self.objectId = Self.objectIdFromUnifiedURL(unifiedUrl)
        var parameters = [String:String]()
        components.queryItems?.forEach {
            parameters[$0.name] = $0.value
        }
        self.queryItems = parameters
    }
}
