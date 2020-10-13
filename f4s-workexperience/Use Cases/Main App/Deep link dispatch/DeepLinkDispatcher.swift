
import WorkfinderCommon

class DeepLinkDispatcher {
    let log: F4SAnalytics
    weak var coordinator: AppCoordinatorProtocol?
    
    init(log: F4SAnalytics, coordinator: AppCoordinatorProtocol) {
        self.log = log
        self.coordinator = coordinator
    }
    
    func dispatch(info: DeeplinkDispatchInfo) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let coordinator = self.coordinator else { return }
            let source = ApplicationSource(deeplinkSource: info.source)
            let log = self.log
            
            switch info.objectType {
            case .recommendation:
                switch info.source {
                case .deeplink:
                    log.track(TrackingEvent(type: TrackEventType.uc_recommendation_deeplink_start))
                    coordinator.showRecommendation(uuid: info.objectId, applicationSource: source)
                    log.track(TrackingEvent(type: TrackEventType.uc_recommendation_deeplink_convert))
                case .pushNotification:
                    log.track(TrackingEvent(type: TrackEventType.uc_recommendation_pushNotification_start))
                    coordinator.showRecommendation(uuid: info.objectId, applicationSource: source)
                    log.track(TrackingEvent(type: TrackEventType.uc_recommendation_pushNotification_convert))
                }
            case .placement:
                coordinator.showApplications(uuid: info.objectId)
            }
        }
    }
}
