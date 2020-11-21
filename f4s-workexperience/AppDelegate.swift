
import UIKit
import WorkfinderCommon

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var deviceToken: String?
    var masterBuilder: MasterBuilder!
    var appCoordinator: AppCoordinatorProtocol!
    
    var log: F4SAnalyticsAndDebugging { return appCoordinator.log }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if ProcessInfo.processInfo.arguments.contains("isUnitTesting") { return true }
        let localStore = LocalStore()
        LocalStoreMigrationsRunner().run(localStore: localStore)
        UIApplication.shared.applicationIconBadgeNumber = 0
        masterBuilder = MasterBuilder(launchOptions: launchOptions)
        window = masterBuilder.window
        startApp()
        return true
    }
    
    func startApp() {
        appCoordinator = self.masterBuilder.buildAppCoordinator()
        appCoordinator.start()
    }
    
    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        // Get URL components from the incoming user activity
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
            let incomingURL = userActivity.webpageURL
            else { return false }
        print("Incoming URL: \(incomingURL)")
        let task = URLSession.shared.dataTask(with: incomingURL, completionHandler: { [weak self] (data, response, error) in
            guard let resolvedURL = response?.url else { return }
            // use the fully resolved link to navigate somewhere in the app.
            _ = self?.appCoordinator.handleDeepLinkUrl(url: resolvedURL)
        })
        task.resume()
        return true
    }
    
    // Handle being invoked from deep links or a smart banner somewhere out there on the web
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return appCoordinator.handleDeepLinkUrl(url: url)
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
        appCoordinator?.registerDevice(token: deviceToken)
    }
    
    func application(_: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        log.error(error, functionName: #function, fileName: #file, lineNumber: #line)
    }
    
    // This method handles notifications arriving whether the app was running already or the notification opened the app
    func application(_: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("Remote notification called: \(#function)")
        DispatchQueue.main.async { [ weak self] in
            guard let pushNotification = PushNotification(userInfo: userInfo) else { return
            }
            self?.appCoordinator.handlePushNotification(pushNotification)
            completionHandler(UIBackgroundFetchResult.newData)
        }
    }
    
    // MARK:- Handle restoration of background session
    func application(_ application: UIApplication,
                     handleEventsForBackgroundURLSession identifier: String,
                     completionHandler: @escaping () -> Void) {

        
    }

}



















