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
}


public struct TrackEvent {
    public let type: TrackEventType
    public let additionalProperties: [String: Any]?
    public var name: String { return type.rawValue }
    init(type: TrackEventType, additionalProperties: [String:Any]? = nil) {
        self.type = type
        self.additionalProperties = additionalProperties
    }
}

public class TrackEventFactory {
    public enum TabName: String {
        case applications
        case notifications
        case search
    }
    
    public static func makeAppOpen() -> TrackEvent { TrackEvent(type: .appOpen) }
    public static func makeCompanyView() -> TrackEvent { TrackEvent(type: .companyView) }
    public static func makeApplyComplete() -> TrackEvent { TrackEvent(type: .applyComplete) }
    public static func makeFirstUse() -> TrackEvent { TrackEvent(type: .firstUse) }
    
    public static func makeTabTap(tab: TabName) -> TrackEvent {
        TrackEvent(
            type: .tabTap,
            additionalProperties: ["navigation_item": tab.rawValue]
        )
    }
    
    public static func makeApplyStart(
        hostRowIndex: Int,
        host: F4SUUID,
        company: F4SUUID) -> TrackEvent {
        TrackEvent(
            type: .applyStart,
            additionalProperties: [
                "host_chosen_position": hostRowIndex,
                "host_id": host,
                "company_id": company
            ]
        )
    }
}
