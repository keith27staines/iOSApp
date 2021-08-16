
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
            case .interviewInvite:
                log.track(.recommendation_deeplink_start)
                coordinator.routeInterviewInvite(id: routingInfo.objectId, appSource: source)
                log.track(.interviewInvite_deeplink_convert)
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
            case .review:
                log.track(.nps_deeplink_start)
                guard let uuid = routingInfo.objectId else { return }
                coordinator.routeReview(reviewUuid: uuid, appSource: source, queryItems: routingInfo.queryItems)
                log.track(.nps_deeplink_convert)
            case .projects:
                log.track(.projects_deeplink_start)
                coordinator.routeLiveProjects(appSource: source)
                log.track(.projects_deeplink_convert)
            case .studentDashboard:
                log.track(.students_dashboard_start)
                coordinator.routeStudentsDashboard(appSource: source)
                log.track(.students_dashboard_convert)
            }
        }
    }
}
