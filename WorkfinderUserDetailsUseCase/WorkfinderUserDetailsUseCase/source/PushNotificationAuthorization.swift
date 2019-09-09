import UIKit
import UserNotifications

public class RequestPushNotificationsAlertFactory {
    
    public var afterAction: (() -> Void)?
    
    public init(center: UNUserNotificationCenter = UNUserNotificationCenter.current()) {
        self.center = center
    }
    
    public func makeAlertViewControllerIfNecessary(completion: @escaping (UIAlertController?) -> Void) {
        center.getNotificationSettings { [weak self] (settings) in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .notDetermined:
                    self?.makeRequestAlert(completion)
                case .denied:
                    self?.makeChangeSettingsAlert(completion)
                case .authorized, .provisional:
                    completion(nil)
                @unknown default:
                    assert(true, "unexpcted authorization status")
                }
            }
        }
    }
    
    private let center: UNUserNotificationCenter
    private lazy var alertTitle = NSLocalizedString("Notifications", comment: "")
    private lazy var settingsMessage = NSLocalizedString("Notifications are disabled for Workfinder so we won't be able to keep you fully updated on the progress of your applications", comment: "")
    private lazy var allowMessage = NSLocalizedString("If you allow Workfinder to use notifications we can keep you more fully upated on the progress of your applications", comment: "")
    
    private lazy var changeSettingsAction = UIAlertAction(
        title: NSLocalizedString("Change settings", comment: ""),
        style: UIAlertAction.Style.default,
        handler: { [weak self] (_) in
        let settingsURL = URL(string: UIApplication.openSettingsURLString)!
        UIApplication.shared.open(settingsURL, options: [:], completionHandler: { _ in
            self?.performAfterActionOnMainThread()
        })
    })
    
    private lazy var allowAction = UIAlertAction(
        title: NSLocalizedString("Allow", comment: ""),
        style: UIAlertAction.Style.default,
        handler: { [weak self] (_) in
        self?.center.requestAuthorization(options: [.alert, .badge, .sound], completionHandler: {_,_ in
            self?.performAfterActionOnMainThread()
        })
    })
    
    private lazy var skipAction = UIAlertAction(
        title: NSLocalizedString("Skip", comment: ""),
        style: UIAlertAction.Style.default,
        handler: { [weak self] (_) in
        self?.performAfterActionOnMainThread()
    })
    
    private func performAfterActionOnMainThread() {
        DispatchQueue.main.async { [weak self] in
            self?.afterAction?()
        }
    }
    
    private func makeChangeSettingsAlert(_ completion: (UIAlertController?) -> Void) {
        completion(makeAlert(title: alertTitle, message: settingsMessage, mainAction: changeSettingsAction))
    }
    
    private func makeRequestAlert(_ completion: (UIAlertController?) -> Void) {
        completion(makeAlert(title: alertTitle, message: allowMessage, mainAction: allowAction))
    }
    
    private func makeAlert(title: String, message: String, mainAction: UIAlertAction) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(skipAction)
        alert.addAction(mainAction)
        return alert
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
