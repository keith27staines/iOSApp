
public enum AppSource: String {
    case deeplink
    case pushNotification
    case homeTabTypeAheadProjects
    case homeTabTypeAheadPeople
    case homeTabSearchResultsProjects
    case homeTabSearchResultsPeople
    case homeTabRecommendations
    case homeTabRecentRoles
    case homeTabTopRoles
    case recommendationsTab
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
