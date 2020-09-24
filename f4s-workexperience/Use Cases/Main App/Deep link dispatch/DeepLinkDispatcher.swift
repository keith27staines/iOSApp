
import WorkfinderCommon

class DeepLinkDispatcher {
    
    init() {
    }
    
    func dispatchDeepLink(_ url: URL, with coordinator: AppCoordinatorProtocol) {
        DispatchQueue.main.async { [weak self] in
            guard
                let self = self,
                let components = self.deeplinkUrlToDispatch(url: url)
                else { return }
            self.dispatch(objectType: components.0, uuid: components.1, with: coordinator)
        }
    }
    
    func dispatch(objectType: String, uuid: F4SUUID?, with coordinator: AppCoordinatorProtocol) {
        switch objectType {
        case "recommendations":
            coordinator.showRecommendation(uuid: uuid, applicationSource: .deeplink)
        case "projects":
            coordinator.showProject(uuid: uuid, applicationSource: .deeplink)
        case "placement":
            break
        default:
            break
        }
    }

    func deeplinkUrlToDispatch(url: URL) -> (String, String?)? {
        if let placementUuid = placementViewRequestUuid(url: url) {
            return ("placement", placementUuid)
        }
        guard
            let path = URLComponents(url: url, resolvingAgainstBaseURL: true)?.path.split(separator: "/")
            else { return nil }
        guard let firstPathComponent = path.first else { return nil }
        if path.count == 1 { return (String(firstPathComponent), nil) }
        let secondPathComponent = String(path[1])
        return (String(firstPathComponent), secondPathComponent)
    }
    
    func placementViewRequestUuid(url: URL) -> F4SUUID? {
        let prefix = "?placement="
        guard
            let path = url.absoluteString.removingPercentEncoding,
            let index: String.Index = path.index(of: prefix)
        else { return nil }
        let offset = path.index(index, offsetBy: prefix.count)
        let uuid = path[offset...]
        return String(uuid)
    }
}
