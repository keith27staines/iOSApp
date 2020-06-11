
import Foundation
import UserNotifications
import WorkfinderCommon

enum NotificationType: String {
    case message
    case rating
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
            @unknown default:
                assert(true, "Unexpected authorizations status")
            }
        }
    }
    
    func getNotificationSettings(completion: @escaping (UNNotificationSettings) -> Void) {
        center.getNotificationSettings { settings in
            completion(settings)
        }
    }
    
    func alertUserNotificationReceived(notificationData: F4SPushNotificationData) {
        guard let rootViewCtrl = UIApplication.shared.delegate?.window??.rootViewController else {
            log.debug("Can't handle notification because there is no root view controller",
                      functionName: #function, fileName: #file, lineNumber: #line)
            return
        }
        
        let title: String = notificationData.alertTitle
        let body: String = notificationData.alertBody
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        let viewAction: UIAlertAction
        viewAction = UIAlertAction(title: NSLocalizedString("View", comment: ""), style: .default) { [weak self] (action) in
            self?.dispatchToBestDestination(notificationData: notificationData)
        }
        let alertController = UIAlertController(title: title, message: body, preferredStyle: .alert)
        alertController.addAction(cancelAction)
        alertController.addAction(viewAction)
        let presenter = rootViewCtrl.topMostViewController ?? rootViewCtrl
        presenter.present(alertController, animated: true) {}
    }
    
    func updateTabBarBadgeNumbers() {
        appCoordinator?.updateBadges()
    }

    func handleRemoteNotification(userInfo: [AnyHashable: Any]) {
        updateTabBarBadgeNumbers() // Always take the opportunity to do this if there is UI to show it
        guard let notificationData = F4SPushNotificationData(userInfo: userInfo) else {
            log.debug("Unrecognised notification. UserInfo: \(userInfo.debugDescription)",
                functionName: #function, fileName: #file, lineNumber: #line)
            return
        }
        let state = UIApplication.shared.applicationState
        if state == .background  || state == .inactive{
            dispatchToBestDestination(notificationData: notificationData)
        } else if state == .active {
            // do nothing
        }
    }
    
    func dispatchToBestDestination(notificationData: F4SPushNotificationData) {
        switch notificationData.type {
        case NotificationType.message:
            break
        case NotificationType.recommendation:
            appCoordinator.showRecommendations(uuid: nil)
        case NotificationType.rating:
            break
        }
    }
}

struct F4SPushNotificationData {
    var alertTitle: String
    var alertBody: String
    var type: NotificationType
    var threadUuid: F4SUUID?
    
    init?(userInfo: [AnyHashable:Any]) {
        guard let aps = userInfo["aps"] as? [AnyHashable: Any] else { return nil }
        guard let typeString = userInfo["type"] as? String else { return nil }
        guard let alert = aps["alert"] as? [AnyHashable: Any] else { return nil }
        guard let notificationType = NotificationType(rawValue: typeString) else { return nil }
        self.alertTitle = (alert["title"] as? String) ?? ""
        self.alertBody = (alert["body"] as? String) ?? ""
        self.type = notificationType
        self.threadUuid = userInfo["thread_uuid"] as? F4SUUID
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
        let userInfo = response.notification.request.content.userInfo
        handleRemoteNotification(userInfo: userInfo)
        completionHandler()
    }
    
    // This method is called when the app is in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        handleRemoteNotification(userInfo: userInfo)
        completionHandler([.badge, .sound])
    }
}
