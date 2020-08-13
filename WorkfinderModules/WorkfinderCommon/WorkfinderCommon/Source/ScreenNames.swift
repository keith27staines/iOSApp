public typealias TrackEventProperty = [String: Any]

public enum ScreenName: String {
    case notSpecified
    case companyClusterList
    case WorkplaceViewController
    case companySearch
    case map
}

public enum TrackEventType: String {
    case firstUse
    case appOpen
    case tabTap
    case companyView
    case applyStart
    case applyComplete
    
    case registerUser
    case signInUser
    
    case projectApplyStart
    case projectApplyNext
    case projectApplyEdit
    case projectApplyBack
    case projectApplyPreview
    case projectApplySubmit
}

public struct TrackingEvent {
    public let name: String
    public let additionalProperties: [String: Any]?

    public init(type: TrackEventType, additionalProperties: [String:Any]? = nil) {
        self.name = type.rawValue
        self.additionalProperties = additionalProperties
    }
    
    public init(name: String, additionalProperties: [String:Any]? = nil) {
        self.name = name
        self.additionalProperties = additionalProperties
    }
    
}
