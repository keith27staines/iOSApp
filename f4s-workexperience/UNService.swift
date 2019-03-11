
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
                globalLog.error(error)
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
        globalLog.debug("Handliong remote notification with user info...")
        globalLog.debug(userInfo)
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
            globalLog.debug("Notification type cannot be extracted from push notification")
            return
        }
        
        if let threadId = userInfo["thread_uuid"] as? String {
            threadUuid = threadId
        }
        if let placementId = userInfo["placement_uuid"] as? String {
            placementUuid = placementId
        }
        
        if isAppActive {
            globalLog.debug("Push notification cannot be processed because the app is active")
            let alert = UIAlertController(title: title, message: body, preferredStyle: .alert)
            let ok = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) //{}
            alert.addAction(ok)
            guard let window = UIApplication.shared.delegate?.window, let rootViewCtrl = window?.rootViewController else {
                globalLog.debug("Can't handle notification because there is no window or no root view controller")
                return
            }
            
            if let topViewController = rootViewCtrl.topMostViewController {
                topViewController.present(alert, animated: true) {}
            } else {
                rootViewCtrl.present(alert, animated: true) {}
            }
            
        } else {
            globalLog.debug("navigating to best destination for notification")
            dispatchToBestDestination(for: type, threadUuid: threadUuid, placementUuid: placementUuid)
        }
    }
    
    func dispatchToBestDestination(for type: NotificationType, threadUuid: F4SUUID?, placementUuid: F4SUUID?) {
        switch type
        {
        case NotificationType.message:
            globalLog.debug("Responding to message push notification by navigating to Timeline")
            TabBarCoordinator.sharedInstance.navigateToTimeline(threadUuid: threadUuid)
            
        case NotificationType.rating:
            globalLog.debug("Responding to rating push notification by presenting rating controller")
            if let topViewCtrl = TabBarCoordinator.sharedInstance.topMostViewController() {
                TabBarCoordinator.sharedInstance.presentRatePlacementPopover(parentCtrl: topViewCtrl, placementUuid: placementUuid!)
            }
        case NotificationType.recommendation:
            globalLog.debug("Responding to recommendation push notification by navigating to Recommendations page")
            TabBarCoordinator.sharedInstance.rewindAndNavigateToRecommendations(from: nil, show: nil)
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
