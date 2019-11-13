
import UIKit
import CoreData
import WorkfinderCommon

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var deviceToken: String?
    var masterBuilder: MasterBuilder!
    var databaseDownloadManager: F4SDatabaseDownloadManagerProtocol!
    var appCoordinator: AppCoordinatorProtocol!
    
    lazy var userService: F4SUserServiceProtocol = { return self.masterBuilder.userService }()
    
    var log: F4SAnalyticsAndDebugging { return appCoordinator.log }
    var selectEnvironmentCoordinator: SelectEnvironmentCoordinating?
    
    // MARK:- Application events
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Prevent the entire application being built if we are just running unit tests
        if ProcessInfo.processInfo.arguments.contains("isUnitTesting") { return true }
 
        DataFixes().run()
        masterBuilder = MasterBuilder(registrar: application, launchOptions: launchOptions)
        window = masterBuilder.window
        let localStore = masterBuilder.localStore
        if localStore.value(key: LocalStore.Key.installationUuid) == nil && Config.environment == .staging {
            let selectEnvironmentCoordinator = SelectEnvironmentCoordinator(parent: nil, router: masterBuilder.rootNavigationRouter) { environmentModel in
                Config.workfinderApiBase = environmentModel.urlString + "/api"
                localStore.setValue(Config.workfinderApiBase, for: LocalStore.Key.workfinderBaseUrl)
                self.startApp()
                self.selectEnvironmentCoordinator = nil
            }
            self.selectEnvironmentCoordinator = selectEnvironmentCoordinator
            selectEnvironmentCoordinator.start()
        } else {
            Config.workfinderApiBase = (localStore.value(key: LocalStore.Key.workfinderBaseUrl) as? String) ?? Config.workfinderApiBase
            self.startApp()
        }
        return true
    }
    
    func startApp() {
        appCoordinator = self.masterBuilder.buildAppCoordinator()
        appCoordinator.start()
        databaseDownloadManager = self.masterBuilder.databaseDownloadManager
    }
    
    // Handle being invoked from a universal link in safari running on the current device
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        guard let url = userActivity.webpageURL else {
            return false
        }
        setInvokingUrl(url)
        return true
    }
    
    // Handle being invoked from a smart banner somewhere out there on the web
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
        self.saveContext()
        log.updateHistory()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        self.saveContext()
    }
    
    func application(_: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        guard let appInstallationUuid = masterBuilder.appInstallationUuidLogic.registeredInstallationUuid else { return }
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        let token = tokenParts.joined()
        userService.enablePushNotificationForUser(installationUuid: appInstallationUuid, withDeviceToken: token) { [weak self] (result) in
            switch result {
            case .error(let error):
                self?.log.error(error, functionName: #function, fileName: #file, lineNumber: #line)
            case .success(_):
                self?.log.debug("Notifications enabled on server with token \(token)", functionName: #function, fileName: #file, lineNumber: #line)
            }
        }
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
        databaseDownloadManager?.backgroundSessionCompletionHandler = completionHandler
        databaseDownloadManager?.start()
    }
    
    // MARK: - Setup CoreData
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "f4s-workexperience")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let nserror = error as NSError? {
                self.log.error(nserror, functionName: #function, fileName: #file, lineNumber: #line)
                assertionFailure("error loading coredata persistent store \(nserror)")
                fatalError("Unrecoverable error \(nserror), \(nserror.userInfo)")
            }
        })
        return container
    }()
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                log.error(nserror, functionName: #function, fileName: #file, lineNumber: #line)
                assertionFailure("error saving to coredata context \(nserror)")
            }
        }
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

















