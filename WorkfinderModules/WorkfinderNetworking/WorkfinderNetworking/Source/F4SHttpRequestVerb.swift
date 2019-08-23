/// Enumerates the Http request verbs used in the Workfinder api
public enum F4SHttpRequestVerb {
    case get
    case put
    case patch
    case post
    case delete
    
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
