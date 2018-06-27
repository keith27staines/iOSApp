//
//  AppDelegate.swift
//  f4s-workexperience
//
//  Created by Andreea Rusu on 26/04/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import UIKit
import CoreData
import XCGLogger
import GoogleMaps
import GooglePlaces
import KeychainSwift
import UserNotifications

let log = XCGLogger.default

extension Notification.Name {
    
    static let verificationCodeRecieved = Notification.Name("verificationCodeRecieved")
    
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var deviceToken: String?

    public private (set) var databaseDownloadManager: F4SDatabaseDownloadManager?
    
    func presentForceUpdate() {
        let rootVC = self.window?.rootViewController?.topMostViewController
        let forceUpdateVC = F4SForceAppUpdateViewController()
        rootVC?.present(forceUpdateVC, animated: true, completion: nil)
    }
    
    func presentNoNetworkMustRetry(application: UIApplication, retryOperation: @escaping (UIApplication) -> ()) {
        let rootVC = self.window?.rootViewController?.topMostViewController
        let alert = UIAlertController(
            title: NSLocalizedString("No Network", comment: ""),
            message: NSLocalizedString("Please ensure you have a good network connection while we set things up for you", comment: ""),
            preferredStyle: .alert)
        let retry = UIAlertAction(
            title: NSLocalizedString("Retry", comment: ""),
            style: .default) { (_) in
                alert.dismiss(animated: false, completion: nil)
                retryOperation(application)
        }
        alert.addAction(retry)
        rootVC?.present(alert, animated: true, completion: nil)
    }

    func handleFatalError(error: Error) {
        let rootVC = self.window?.rootViewController
        let alert = UIAlertController(
            title: NSLocalizedString("Workfinder cannot continue", comment: ""),
            message: NSLocalizedString("We are very sorry, this should not have happened but Workfinder has encountered an error it cannot recover from", comment: ""),
            preferredStyle: .alert)
        let retry = UIAlertAction(
            title: NSLocalizedString("Close Workfinder", comment: ""),
            style: .default) { (_) in
                fatalError()
        }
        alert.addAction(retry)
        rootVC?.present(alert, animated: true, completion: nil)
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        do {
            let f4sDebug = try F4SDebug()
            F4SDebug.shared = f4sDebug
        } catch (let error) {
            assertionFailure("Failed to initialize logger: \(error)")
        }
        log.debug("\n\n\n**************\nWorkfinder launched in environement \(Config.ENVIRONMENT)\n**************")
        GMSServices.provideAPIKey(GoogleApiKeys.googleApiKey)
        GMSPlacesClient.provideAPIKey(GoogleApiKeys.googleApiKey)
        registerUser(application: application)
        return true
    }
    
    lazy var userService: F4SUserServiceProtocol = {
        return F4SUserService()
    }()
    
    func versionAuthorizedToContinue(_ application: UIApplication) {
        F4SUserStatusService.shared.beginStatusUpdate()
        userService.registerAnonymousUserOnServer { [weak self] uuid in
            guard let _ = uuid else {
                self?.presentNoNetworkMustRetry(application: application, retryOperation: { (application) in
                    self?.versionAuthorizedToContinue(application)
                })
                return
            }
            self?.onUserAccountConfirmedToExist(application: application)
        }
    }
    
    func onUserAccountConfirmedToExist(application: UIApplication) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.printDebugUserInfo()
            _ = F4SNetworkSessionManager.shared
            F4SUserStatusService.shared.beginStatusUpdate()
            strongSelf.databaseDownloadManager = strongSelf.databaseDownloadManager ?? F4SDatabaseDownloadManager()
            strongSelf.registerApplicationForRemoteNotifications(application)
            strongSelf.databaseDownloadManager?.start()
            guard let window = strongSelf.window else { return }
            let isFirstLaunch = UserDefaults.standard.value(forKey: UserDefaultsKeys.isFirstLaunch) as? Bool ?? true
            if isFirstLaunch {
                guard let ctrl = window.rootViewController?.topMostViewController as? OnboardingViewController else {
                    return
                }
                ctrl.hideOnboardingControls = false
            } else {
                let shouldLoadTimelineValue = UserDefaults.standard.value(forKey: UserDefaultsKeys.shouldLoadTimeline)
                var shouldLoadTimeline: Bool = false
                if let value = shouldLoadTimelineValue {
                    shouldLoadTimeline = value as? Bool ?? false
                }
                let navigationHelper = CustomNavigationHelper.sharedInstance
                if shouldLoadTimeline {
                    navigationHelper.navigateToTimeline(threadUuid: nil)
                } else {
                    navigationHelper.navigateToMap()
                    navigationHelper.mapViewController.shouldRequestAuthorization = false
                }
            }
        }
    }
    
    func printDebugUserInfo() {
        log.debug("***************")
        log.debug("Vendor id = \(UIDevice.current.identifierForVendor!)")
        let userIdKey = UserDefaultsKeys.userUuid
        let k = KeychainSwift()
        let userID = k.get(userIdKey)!
        log.debug("User id = \(userID)")
        log.debug("***************")
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        guard let url = userActivity.webpageURL else {
            return false
        }
        // Handle being invoked from a universal link in safari running on the current device
        if databaseDownloadManager == nil {
            databaseDownloadManager = F4SDatabaseDownloadManager()
        }
        
        setInvokingUrl(url)
        return true
    }
    
    func setInvokingUrl(_ url: URL) {
        log.debug("Invoked from url: \(url.absoluteString)")
        guard let universalLink = UniversalLink(url: url) else {
            return
        }
        switch universalLink {
        case .recommendCompany(let company):
            CustomNavigationHelper.sharedInstance.rewindAndNavigateToRecommendations(from: nil, show: company)
            break
        case .passwordless( _):
            let userInfo: [AnyHashable: Any] = ["url" : url]
            let notification = Notification(
                name: .verificationCodeRecieved,
                object: self,
                userInfo: userInfo)
            NotificationCenter.default.post(notification)
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        // Handle being invoked from a smart banner somewhere out there on the web
        setInvokingUrl(url)
        return true
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        F4SUserStatusService.shared.beginStatusUpdate()
        registerApplicationForRemoteNotifications(application)
    }

    func applicationDidBecomeActive(_ appliction: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        F4SDebug.shared?.updateHistory()
        self.saveContext()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        F4SUserStatusService.shared.beginStatusUpdate()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.f4s.workexperience" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count - 1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "f4s-workexperience", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("f4s-workexperience.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }

        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext() {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
}

// MARK:- Notification
extension AppDelegate {
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        if !notificationSettings.types.isEmpty {
            application.registerForRemoteNotifications()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ApplicationDidRegisterForRemoteNotificationsNotification"), object: self)
        } else {
            log.debug("User declined remote notifications")
            UserDefaults.standard.set(true, forKey: UserDefaultsKeys.didDeclineRemoteNotifications)
        }
    }
    
    func application(_: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        let token = tokenParts.joined()
        userService.enablePushNotificationForUser(withDeviceToken: token) { (result) in
            
        }
    }
    
    func application(_: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        log.error("Failed to register with error \(error)")
    }
    
    func application(_: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let appState = UIApplication.shared.applicationState
        if appState == .active {
            if let window = self.window {
                NotificationHelper.sharedInstance.handleRemoteNotification(userInfo: userInfo, window: window, isAppActive: true)
            }
        } else {
            if let window = self.window {
                NotificationHelper.sharedInstance.handleRemoteNotification(userInfo: userInfo, window: window, isAppActive: false)
            }
        }
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        self.application(application, didReceiveRemoteNotification: userInfo) {
            _ in
            log.debug("Recieved remote notification with userInfo: \(userInfo)")
        }
    }
    
    func registerApplicationForRemoteNotifications(_ application: UIApplication) {
        if application.isRegisteredForRemoteNotifications || (application.currentUserNotificationSettings?.types.contains(.alert))! {
            application.registerForRemoteNotifications()
        }
    }
}

// MARK:- Handle restoration of background session
extension AppDelegate {
    
    func application(_ application: UIApplication,
                     handleEventsForBackgroundURLSession identifier: String,
                     completionHandler: @escaping () -> Void) {
        databaseDownloadManager = F4SDatabaseDownloadManager(backgroundSessionCompletionHandler: completionHandler)
        databaseDownloadManager?.start()
    }
}

