
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
}

extension UNService : UNUserNotificationCenterDelegate {

    // This method is called when the user taps a notification banner
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        guard response.actionIdentifier != UNNotificationDismissActionIdentifier else { return }
        print("User tapped remote notification: \(#function)")
        let userInfo = response.notification.request.content.userInfo
        let pushNotification = PushNotification(userInfo: userInfo)
        appCoordinator.handlePushNotification(pushNotification)
        completionHandler()
    }
    
    /// This method is where the app decides what to do if a notification is received while the app is in the
    /// foreground. The approaches here is just to call the completion handler to tell iOS to show the notification
    /// banner to the user, update badges and play a sound.
    /// In this approach, the handling of the notification is deferred until the user taps the banner
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Remote notification received with app in FOREGROUND: \(#function)")
//        let userInfo = notification.request.content.userInfo
//        let pushNotification = PushNotification(userInfo: userInfo)
//        appCoordinator.handlePushNotification(pushNotification)
        completionHandler([.badge, .sound, .alert])
    }
    
}
