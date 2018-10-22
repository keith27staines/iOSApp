
import Foundation
import UserNotifications

class UNService {
    static let shared: UNService = UNService()
    let center = UNUserNotificationCenter.current()
    
    func authorize() {
        center.requestAuthorization(options: [.alert,.badge, .sound]) { (success, error) in
            if let error = error {
                log.error(error)
            }
        }
    }
    
    func getNotificationSettings(completion: @escaping (UNNotificationSettings) -> Void) {
        center.getNotificationSettings { settings in
            completion(settings)
        }
    }

    func handleRemoteNotification(userInfo: [AnyHashable: Any], window: UIWindow, isAppActive: Bool) {
        log.debug(userInfo)
        F4SUserStatusService.shared.beginStatusUpdate()
        
        var title: String = ""
        var body: String = ""
        var threadUuid: String = ""
        var placementUuid: String = ""
        
        if let aps = userInfo["aps"] as? [AnyHashable: Any] {
            if let alert = aps["alert"] as? [AnyHashable: Any] {
                if let t = alert["title"] as? String {
                    title = t
                }
                if let b = alert["body"] as? String {
                    body = b
                }
            }
        }
        
        guard let type = extractNotificationType(userInfo: userInfo) else {
            return
        }
        
        if let threadId = userInfo["thread_uuid"] as? String {
            threadUuid = threadId
        }
        if let placementId = userInfo["placement_uuid"] as? String {
            placementUuid = placementId
        }
        
        if isAppActive {
            let alert = UIAlertController(title: title, message: body, preferredStyle: .alert)
            let ok = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) //{}
            alert.addAction(ok)
            if let window = UIApplication.shared.delegate?.window {
                if let rootViewCtrl = window?.rootViewController {
                    if let topViewController = rootViewCtrl.topMostViewController {
                        topViewController.present(alert, animated: true) {}
                    } else {
                        rootViewCtrl.present(alert, animated: true) {}
                    }
                }
            }
        } else {
            dispatchToBestDestination(for: type, threadUuid: threadUuid, placementUuid: placementUuid)
        }

    }
    
    func dispatchToBestDestination(for type: NotificationType, threadUuid: F4SUUID?, placementUuid: F4SUUID?) {
        switch type
        {
        case NotificationType.message:
            CustomNavigationHelper.sharedInstance.navigateToTimeline(threadUuid: threadUuid)
            
        case NotificationType.rating:
            if let topViewCtrl = CustomNavigationHelper.sharedInstance.topMostViewController() {
                CustomNavigationHelper.sharedInstance.presentRatePlacementPopover(parentCtrl: topViewCtrl, placementUuid: placementUuid!)
            }
        case NotificationType.recommendation:
            CustomNavigationHelper.sharedInstance.rewindAndNavigateToRecommendations(from: nil, show: nil)
        }
    }
    
    func extractNotificationType(userInfo:[AnyHashable: Any]) -> NotificationType? {
        guard let typeString = userInfo["type"] as? String else { return nil }
        switch typeString
        {
        case NotificationType.message.rawValue:
            return NotificationType.message
        case NotificationType.rating.rawValue:
            return NotificationType.rating
        case NotificationType.recommendation.rawValue:
            return NotificationType.recommendation
        default:
            assert(false, "Unexpected or missing type string: \(typeString)")
            return nil
        }
    }
}
