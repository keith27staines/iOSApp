
import Foundation
import UserNotifications
import WorkfinderCommon

enum NotificationType: String {
    case other
    case recommendation
}

class UNService : NSObject {
    
    private let didDeclineKey: String = "didDeclineRemoteNotifications"
    weak var appCoordinator: AppCoordinatorProtocol!
    let center = UNUserNotificationCenter.current()
    var log: F4SAnalyticsAndDebugging { return appCoordinator.log }
    
    init(appCoordinator: AppCoordinatorProtocol) {
        self.appCoordinator = appCoordinator
        super.init()
        center.delegate = self
    }

    func authorize() {
        center.requestAuthorization(options: [.alert,.badge, .sound]) { isAuthorized, _ in
            guard isAuthorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func updateTabBarBadgeNumbers() {
        appCoordinator?.updateBadges()
    }

    func handleRemoteNotification(userInfo: [AnyHashable: Any]) {
        updateTabBarBadgeNumbers() // Always take the opportunity to do this if there is UI to show it
        guard let notification = PushNotification(userInfo: userInfo) else {
            log.debug("Unrecognised notification. UserInfo: \(userInfo.debugDescription)",
                functionName: #function, fileName: #file, lineNumber: #line)
            return
        }
        let state = UIApplication.shared.applicationState
        if state == .background  || state == .inactive{
            dispatchToBestDestination(notificationData: notification)
        } else if state == .active {
            // do nothing
        }
    }
    
    func dispatchToBestDestination(notificationData: PushNotification) {
        switch notificationData.type {
        case NotificationType.recommendation:
            appCoordinator.showRecommendation(uuid: nil)
        case NotificationType.other:
            appCoordinator.showRecommendation(uuid: nil)
        }
    }
}

struct PushNotification {
    var type: NotificationType
    
    init?(userInfo: [AnyHashable:Any]) {
        guard let _ = userInfo["aps"] as? [AnyHashable: Any] else { return nil }
        let typeString = userInfo["type"] as? String ?? "other"
        guard let notificationType = NotificationType(rawValue: typeString) else { return nil }
        self.type = notificationType
    }
    
    func extractNotificationType(userInfo:[AnyHashable: Any]) -> NotificationType? {
        guard let typeString = userInfo["type"] as? String,
            let notificationType = NotificationType(rawValue: typeString) else { return nil }
        return notificationType
    }
    
}

extension UNService : UNUserNotificationCenterDelegate {

    // This method is called when:
    // 1. The application was not previously running but has been instantiated by the user tapping a notification
    // 2. The application was running in the background and the user tapped a notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Remote notification received with app in BACKGROUND: \(#function)")
        let userInfo = response.notification.request.content.userInfo
        handleRemoteNotification(userInfo: userInfo)
        completionHandler()
    }
    
    // This method is called when the app is in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Remote notification received with app in FOREGROUND: \(#function)")
        let userInfo = notification.request.content.userInfo
        handleRemoteNotification(userInfo: userInfo)
        completionHandler([.badge, .sound])
    }
}
