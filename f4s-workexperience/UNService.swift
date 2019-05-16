
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
        center.getNotificationSettings { [weak self] (settings) in
            guard let center = self?.center else { return }
            switch settings.authorizationStatus {
            case .notDetermined:
                center.requestAuthorization(options: [.alert,.badge, .sound]) {_,_ in }
            case .denied:
                let settings = URL(string: UIApplication.openSettingsURLString)!
                UIApplication.shared.open(settings, options: [:], completionHandler: nil)
            case .authorized, .provisional:
                break
            }
        }

    }
    
    func getNotificationSettings(completion: @escaping (UNNotificationSettings) -> Void) {
        center.getNotificationSettings { settings in
            completion(settings)
        }
    }
    
    func alertUserNotificationReceived(userInfo: [AnyHashable: Any]) {
        guard let rootViewCtrl = UIApplication.shared.delegate?.window??.rootViewController else {
            globalLog.debug("Can't handle notification because there is no root view controller")
            return
        }
        guard let type = extractNotificationType(userInfo: userInfo) else { return }
        var title: String = ""
        var body: String = ""
        (title,body) = extractTitleAndBody(userInfo: userInfo)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertAction.Style.cancel, handler: nil)
        let viewAction: UIAlertAction
        switch type {
        case .message:
            title = NSLocalizedString("You have a new message", comment: "")
            viewAction = UIAlertAction(title: "View", style: UIAlertAction.Style.default, handler: { (_) in
                TabBarCoordinator.sharedInstance.navigateToTimeline(threadUuid: nil)
            })
        case .recommendation:
            title = NSLocalizedString("We have new recommendations for you", comment: "")
            viewAction = UIAlertAction(title: "View", style: UIAlertAction.Style.default, handler: { (_) in
                TabBarCoordinator.sharedInstance.navigateToRecommendations()
            })
        case .rating: return
        }
        let alertController = UIAlertController(title: title, message: body, preferredStyle: .alert)
        alertController.addAction(cancelAction)
        alertController.addAction(viewAction)
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
    
    func extractTitleAndBody(userInfo:[AnyHashable: Any]) -> (title:String, body:String) {
        guard
            let aps = userInfo["aps"] as? [AnyHashable: Any],
            let alert = aps["alert"] as? [AnyHashable: Any] else { return ("", "") }
        let title = (alert["title"] as? String) ?? ""
        let body = (alert["body"] as? String) ?? ""
        return (title, body)
    }
}

extension UNService : UNUserNotificationCenterDelegate {

    // This method is called when:
    // 1. The application was not previously running but has been instantiated by the user tapping a notification
    // 2. The application was running in the background and the user tapped a notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        handleRemoteNotification(userInfo: userInfo)
        completionHandler()
    }
    
    // This method is called when the app is in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        globalLog.debug("Notification received while in foreground with serInfo \n\(userInfo)")
        handleRemoteNotification(userInfo: userInfo)
        completionHandler([.badge, .sound])
    }
}
