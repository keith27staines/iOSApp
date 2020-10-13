
public enum ApplicationSource: String {
    case none
    case deeplink
    case pushNotification
    case searchTab
    case recommendationsTab
    case other
    
    public init(deeplinkSource: DeeplinkDispatchInfo.Source) {
        switch deeplinkSource {
        case .deeplink:
            self = .deeplink
        case .pushNotification:
            self = .pushNotification
        }
    }
}
