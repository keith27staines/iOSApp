
import WorkfinderCommon

class DeepLinkRouter {
    let log: F4SAnalytics
    weak var coordinator: AppCoordinatorProtocol?
    
    init(log: F4SAnalytics, coordinator: AppCoordinatorProtocol) {
        self.log = log
        self.coordinator = coordinator
    }
    
    func route(routingInfo: DeeplinkRoutingInfo) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let coordinator = self.coordinator else { return }
            let source = AppSource(deeplinkSource: routingInfo.source)
            let log = self.log
            
            switch routingInfo.objectType {
            case .recommendation:
                switch routingInfo.source {
                case .deeplink:
                    log.track(.recommendation_deeplink_start)
                    coordinator.routeRecommendation(recommendationUuid: routingInfo.objectId, appSource: source)
                    log.track(.recommendation_deeplink_convert)
                case .pushNotification:
                    log.track(.recommendation_pushnotification_start)
                    coordinator.routeRecommendation(recommendationUuid: routingInfo.objectId, appSource: source)
                    log.track(.recommendation_pushnotification_convert)
                }
            case .placement:
                log.track(.placement_deeplink_start)
                coordinator.routeApplication(placementUuid: routingInfo.objectId, appSource: source)
                log.track(.placement_deeplink_convert)
            }
        }
    }
}