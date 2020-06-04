
import UIKit
import WorkfinderCommon

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var deviceToken: String?
    var masterBuilder: MasterBuilder!
    var companyFileDownloadManager: F4SCompanyDownloadManagerProtocol!
    var appCoordinator: AppCoordinatorProtocol!
    
    var log: F4SAnalyticsAndDebugging { return appCoordinator.log }
    // MARK:- Application events
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if ProcessInfo.processInfo.arguments.contains("isUnitTesting") { return true }
        let localStore = LocalStore()
        LocalStoreMigrationsRunner().run(localStore: localStore)
        masterBuilder = MasterBuilder(registrar: application, launchOptions: launchOptions)
        window = masterBuilder.window
        startApp()
        return true
    }
    
    func startApp() {
        appCoordinator = self.masterBuilder.buildAppCoordinator()
        appCoordinator.start()
        companyFileDownloadManager = self.masterBuilder.companyFileDownloadManager
    }
    
    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool
    {
        // Get URL components from the incoming user activity
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
            let incomingURL = userActivity.webpageURL,
            let components = NSURLComponents(url: incomingURL, resolvingAgainstBaseURL: true) else {
            return false
        }

        // Check for specific URL components that you need
        guard let path = components.path,
        let params = components.queryItems else { return false }
        setInvokingUrl(incomingURL)
        return true  // If can't handle, return false
    }
    
    // Handle being invoked from deep links or a smart banner somewhere out there on the web
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        setInvokingUrl(url)
        return true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
    }
    
    func applicationDidBecomeActive(_ appliction: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.

    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {

    }
    
    func application(_: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        guard let userUuid = masterBuilder.localStore.value(key: LocalStore.Key.userUuid) as? F4SUUID else { return }
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        let token = tokenParts.joined()
//        userService.enablePushNotificationForUser(installationUuid: userUuid, withDeviceToken: token) { [weak self] (result) in
//            switch result {
//            case .error(let error):
//                self?.log.error(error, functionName: #function, fileName: #file, lineNumber: #line)
//            case .success(_):
//                self?.log.debug("Notifications enabled on server with token \(token)", functionName: #function, fileName: #file, lineNumber: #line)
//            }
//        }
    }
    
    func application(_: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        log.error(error, functionName: #function, fileName: #file, lineNumber: #line)
    }
    
    // This method handles notifications arriving whether the app was running already or the notification opened the app
    func application(_: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        DispatchQueue.main.async { [ weak self] in
            self?.appCoordinator.handleRemoteNotification(userInfo: userInfo)
            completionHandler(UIBackgroundFetchResult.newData)
        }
    }
    
    // MARK:- Handle restoration of background session
    func application(_ application: UIApplication,
                     handleEventsForBackgroundURLSession identifier: String,
                     completionHandler: @escaping () -> Void) {
        companyFileDownloadManager?.backgroundSessionCompletionHandler = completionHandler
        companyFileDownloadManager?.start()
    }

}

// MARK: helpers
extension AppDelegate {
    
    func setInvokingUrl(_ url: URL) {
        guard let universalLink = UniversalLink(url: url) else { return }
        switch universalLink {
        case .recommendCompany(_):
            appCoordinator.showRecommendations()

        case .passwordless( _):
            let userInfo: [AnyHashable: Any] = ["url" : url]
            let notification = Notification(
                name: .verificationCodeRecieved,
                object: self,
                userInfo: userInfo)
            NotificationCenter.default.post(notification)
        }
    }
}

















