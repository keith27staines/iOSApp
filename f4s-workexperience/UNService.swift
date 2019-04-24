
import Foundation
import UserNotifications

enum NotificationType: String {
    case message
    case rating
    case recommendation
}

class UNService : NSObject {
    
    private let didDeclineKey: String = "didDeclineRemoteNotifications"
    
    static let shared: UNService = {
        let service = UNService()
        service.center.delegate = service
        return service
    }()
    
    let center = UNUserNotificationCenter.current()
    
    func authorize() {
        center.requestAuthorization(options: [.alert,.badge, .sound]) { [weak self] (success, error) in
            guard let this = self else { return }
            if let error = error {
                globalLog.error(error)
            }
            this.userDefaults.setValue(!success, forKey: this.didDeclineKey)
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
    
    func alertUserNotificationReceived(userInfo: [AnyHashable: Any]) {
        guard
            let window = UIApplication.shared.delegate?.window,
            let rootViewCtrl = window?.rootViewController
        else {
            globalLog.debug("Can't handle notification because there is no window or no root view controller")
            return
        }
        
        guard
            let aps = userInfo["aps"] as? [AnyHashable: Any],
            let alert = aps["alert"] as? [AnyHashable: Any]
        else { return }
        
        let title: String = (alert["title"] as? String) ?? ""
        let body: String = (alert["body"] as? String) ?? ""

        let alertController = UIAlertController(title: title, message: body, preferredStyle: .alert)
        let ok = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default)
        alertController.addAction(ok)
        
        let presenter = rootViewCtrl.topMostViewController ?? rootViewCtrl
        presenter.present(alertController, animated: true) {}
    }
    
    func updateBadgeNumbers() {
        F4SUserStatusService.shared.beginStatusUpdate()
        TabBarCoordinator.sharedInstance.updateBadges()
    }

    func handleRemoteNotification(userInfo: [AnyHashable: Any]) {
        globalLog.debug("Handling remote notification with user info...")
        globalLog.debug(userInfo)
        updateBadgeNumbers()  // Always take the chance to do this in response to any notification

        let state = UIApplication.shared.applicationState
        if state == .background  || state == .inactive{
            globalLog.debug("navigating to best destination for notification")
            dispatchToBestDestination(userInfo: userInfo)
        }else if state == .active {
            globalLog.debug("Push notification cannot be processed because the app is active")
            alertUserNotificationReceived(userInfo: userInfo)
        }
    }
    
    func dispatchToBestDestination(userInfo: [AnyHashable: Any]) {
        
        guard let type = extractNotificationType(userInfo: userInfo) else { return }
        
        switch type {
        case NotificationType.message:
            globalLog.debug("Responding to message push notification by navigating to Timeline")
            if let threadUuid = userInfo["thread_uuid"] as? String {
                TabBarCoordinator.sharedInstance.navigateToTimeline(threadUuid: threadUuid)
            }
            
        case NotificationType.rating:
            globalLog.debug("Responding to rating push notification by presenting rating controller")
            guard
                let topViewCtrl = TabBarCoordinator.sharedInstance.topMostViewController(),
                let placementUuid = userInfo["placement_uuid"] as? String
                else { return }
            TabBarCoordinator.sharedInstance.presentRatePlacementPopover(parentCtrl: topViewCtrl, placementUuid: placementUuid)
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
}

extension UNService : UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
        
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        handleRemoteNotification(userInfo: userInfo)
        completionHandler()
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        print("Notification received while in foreground with serInfo \n\(userInfo)")
        let settings: UNNotificationPresentationOptions = .badge
        updateBadgeNumbers()
        completionHandler(settings)
    }
}
