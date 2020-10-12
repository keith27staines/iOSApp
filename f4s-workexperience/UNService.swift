
import Foundation
import UserNotifications
import WorkfinderCommon

class UNService : NSObject {
    
    private let didDeclineKey: String = "didDeclineRemoteNotifications"
    private let userRepository: UserRepositoryProtocol
    weak var appCoordinator: AppCoordinatorProtocol!
    let center = UNUserNotificationCenter.current()
    var log: F4SAnalyticsAndDebugging { return appCoordinator.log }
    var permissionHasBeenRequested = false
    
    init(appCoordinator: AppCoordinatorProtocol, userRepository: UserRepositoryProtocol) {
        self.appCoordinator = appCoordinator
        self.userRepository = userRepository
        super.init()
        center.delegate = self
    }
    
    func authorize(from viewController: UIViewController) {
        center.getNotificationSettings(completionHandler: { (settings) in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                switch settings.authorizationStatus {
                case .notDetermined:
                    guard self.permissionHasBeenRequested == false else { return }
                    self.permissionHasBeenRequested = true
                    self.suggestEnableRecommendations(from: viewController)
                case .denied:
                    guard self.permissionHasBeenRequested == false else { return }
                    self.permissionHasBeenRequested = true
                    self.directUserToSettings(from: viewController)
                case .authorized, .provisional, .ephemeral:
                    UIApplication.shared.registerForRemoteNotifications()
                @unknown default:
                    break
                }
            }
        })
    }
    
    private func suggestEnableRecommendations(from viewController: UIViewController) {
        guard let _ = userRepository.loadUser().uuid else { return }
        let alertController = UIAlertController (title: "Would you like to receive notifications when you have new recommendations?", message: "We recommend positions matched to you", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Not now", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        
        let settingsAction = UIAlertAction(title: "Enable notifications", style: .default) { (_) -> Void in
            

            self.center.requestAuthorization(options: [.alert,.badge, .sound]) { [weak self] isAuthorized, _ in
                guard let self = self, isAuthorized else { return }
                DispatchQueue.main.async { UIApplication.shared.registerForRemoteNotifications() }
                self.permissionHasBeenRequested = true
            }
        }
        alertController.addAction(settingsAction)
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    private func directUserToSettings(from viewController: UIViewController) {
        let alertController = UIAlertController (title: "You haven't enabled notifications", message: "Notifications will alert immediately you when we have a new recommendation matched to you. You can enable notifications for Workfinder in settings", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Not now", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
            guard
                let settingsUrl = URL(string: UIApplication.openSettingsURLString),
                UIApplication.shared.canOpenURL(settingsUrl) else { return }
                UIApplication.shared.open(settingsUrl) { (success) in }
        }
        alertController.addAction(settingsAction)
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    func updateTabBarBadgeNumbers() {
        appCoordinator?.updateBadges()
    }

    func handleRemoteNotification(userInfo: [AnyHashable: Any]) {
        print(userInfo)
        updateTabBarBadgeNumbers() // Always take the opportunity to do this if there is UI to show it
        guard let notification = PushNotification(userInfo: userInfo) else {
            log.debug("Unrecognised notification. UserInfo: \(userInfo.debugDescription)",
                functionName: #function, fileName: #file, lineNumber: #line)
            return
        }
        let state = UIApplication.shared.applicationState
        if state == .background  || state == .inactive{
            dispatchToBestDestination(pushNotification: notification)
        } else if state == .active {
            // do nothing
        }
    }
    
    func dispatchToBestDestination(pushNotification: PushNotification) {
//        switch notificationData.type {
//        case NotificationType.recommendation:
//            appCoordinator.showRecommendation(uuid: nil, applicationSource: .pushNotification)
//        case NotificationType.other:
//            appCoordinator.showRecommendation(uuid: nil, applicationSource: .none)
//        }
    }
}

struct PushNotification {
    var text: String?
    var objectType: String?
    var objectId:  F4SUUID?
    var action: String?
    
    init?(userInfo: [AnyHashable:Any]) {
        guard let _ = userInfo["aps"] as? [AnyHashable: Any] else { return nil }
        objectType = userInfo["object_type"] as? String
        objectId = userInfo["object_id"] as? String
        action = userInfo["action"] as? String
    }
}

extension UNService : UNUserNotificationCenterDelegate {

    // This method is called when:
    // 1. The application was not previously running but has been instantiated by the user tapping a notification
    // 2. The application was running in the background and the user tapped a notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        guard response.actionIdentifier != UNNotificationDismissActionIdentifier else { return }
        print("User tapped remote notification: \(#function)")
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
