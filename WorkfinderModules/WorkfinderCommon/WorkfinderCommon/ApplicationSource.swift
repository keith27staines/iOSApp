
public enum ApplicationSource: String {
    case none
    case deeplink
    case pushNotification
    case searchTab
    case recommendationsTab
    case other
    
    public init(source: DeeplinkDispatchInfo.Source) {
        switch source {
        case .deeplink:
            self = .deeplink
        case .pushNotification:
            self = .pushNotification
        }
    }
}
