
import WorkfinderCommon

class DeepLinkDispatcher {
    
    init() {
    }
    
    func dispatchDeepLink(_ url: URL, with coordinator: AppCoordinatorProtocol) {
        guard
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
            else { return }
        let path = components.path.split(separator: "/")
        guard let firstPathComponent = path.first else { return }
        DispatchQueue.main.async {
            let lastPathComponent = String(path.last ?? "")
            switch firstPathComponent {
            case "recommendations":
                coordinator.showRecommendation(uuid: lastPathComponent)
            case "projects":
                coordinator.showProject(uuid: lastPathComponent)
            default:
                break
            }
        }
    }
}
