/// Enumerates the Http request verbs used in the Workfinder api
public enum RequestVerb {
    case get
    case put
    case patch
    case post
    case delete
    
    public init?(verbName: String) {
        switch verbName.lowercased() {
        case "get": self = .get
        case "put": self = .put
        case "patch": self = .patch
        case "post": self = .post
        case "delete": self = .delete
        default: return nil
        }
    }
    
    public var name: String {
        switch self {
        case .get:
            return "GET"
        case .put:
            return "PUT"
        case .patch:
            return "PATCH"
        case .post:
            return "POST"
        case .delete:
            return "DELETE"
        }
    }
}
