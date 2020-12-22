
public enum ApplicationSource: String {
    case none
    case deeplink
    case pushNotification
    case homeTab
    case homeTabTypeAheadProjects
    case homeTabTypeAheadPeople
    case homeTabSearchResultsProjects
    case homeTabSearchResultsPeople
    case homeTabRecommendations
    case homeTabRecentRoles
    case homeTabTopRoles
    case recommendationsTab
    case other
    case unspecified
    
    public init(deeplinkSource: DeeplinkDispatchInfo.Source) {
        switch deeplinkSource {
        case .deeplink:
            self = .deeplink
        case .pushNotification:
            self = .pushNotification
        }
    }
}
