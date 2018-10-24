
import Foundation
import UserNotifications


enum NotificationType: String {
    case message
    case rating
    case recommendation
}

class UNService : NSObject {
    
    private let didDeclineKey: String = "didDeclineRemoteNotifications"
    
    static let shared: UNService = UNService()
    let center = UNUserNotificationCenter.current()
    
    func configure() {
        center.delegate = self
    }
    
    func authorize() {
        center.requestAuthorization(options: [.alert,.badge, .sound]) { [weak self] (success, error) in
            guard let this = self else { return }
            if let error = error {
                log.error(error)
            }
            this.userDefaults.setValue(!success, forKey: this.didDeclineKey)
            this.configure()
        }
    }
    
    private var userDefaults: UserDefaults { return UserDefaults.standard }
    
    var userHasNotAgreedToNotifications: Bool {
        return userHasNotBeenAskedToAllowNotifications || userDidDeclineNotifications
    }
    
    var userHasNotBeenAskedToAllowNotifications: Bool {
        return nil == userDefaults.value(forKey: didDeclineKey)
    }
    
    var userDidDeclineNotifications: Bool {
        return userDefaults.value(forKey: didDeclineKey) as? Bool ?? false
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
        guard let typeString = userInfo["type"] as? String,
        let notificationType = NotificationType(rawValue: typeString) else { return nil }
        return notificationType
    }
    
    func processRemoteNotification(notification: UNNotification) {
        let userInfo = notification.request.content.userInfo
        guard let typeString = userInfo["type"] as? String,
            let notificationType = NotificationType(rawValue: typeString) else { return }
        let threadUuid: String = userInfo["thread_uuid"] as? String ?? ""
        let placementUuid: String = userInfo["placement_uuid"] as? String ?? ""
        dispatchToBestDestination(for: notificationType, threadUuid: threadUuid
            , placementUuid: placementUuid)
    }
}

extension UNService : UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
        
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let notification = response.notification
        let userInfo = notification.request.content.userInfo
        print("User responded to notification with userInfo \n\(userInfo)")
        processRemoteNotification(notification: notification)
        
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        print("Notification received while in foreground with serInfo \n\(userInfo)")
        let settings: UNNotificationPresentationOptions = .badge
        F4SUserStatusService.shared.beginStatusUpdate()
        completionHandler(settings)
    }
}
