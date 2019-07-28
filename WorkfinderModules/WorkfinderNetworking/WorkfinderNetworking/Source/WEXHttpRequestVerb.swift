import Foundation


/// This is almost obsolete, prefer to use the F4S equivalent
public enum WEXHTTPRequestVerb {
    case get
    case put(Data)
    case patch(Data)
    case post(Data)
    case delete
    
    public var name: String {
        switch self {
        case .get: return "GET"
        case .put(_): return "PUT"
        case .patch: return "PATCH"
        case .post: return "POST"
        case .delete: return "DELETE"
        }
    }
}
