
public enum AppSource: String {
    case deeplink
    case pushnotification
    case homeTabTypeaheadProjectsList
    case homeTabTypeaheadPeopleList
    case homeTabSearchResultsProjectsList
    case homeTabSearchResultsPeopleList
    case homeTabRecommendationsList
    case homeTabRecentRolesList
    case homeTabTopRolesList
    case recommendationsTab
    case unspecified
    
    public init(deeplinkSource: DeeplinkDispatchInfo.Source) {
        switch deeplinkSource {
        case .deeplink:
            self = .deeplink
        case .pushNotification:
            self = .pushnotification
        }
    }
}
