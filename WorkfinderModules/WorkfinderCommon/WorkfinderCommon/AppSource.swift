
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
    case applicationsTab
    case recommendationsTab
    case userChoice
    case unspecified
    
    public init(deeplinkSource: DeeplinkRoutingInfo.Source) {
        switch deeplinkSource {
        case .deeplink:
            self = .deeplink
        case .pushNotification:
            self = .pushnotification
        }
    }
}
