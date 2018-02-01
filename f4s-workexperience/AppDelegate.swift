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

let log = XCGLogger.default

extension Notification.Name {
    
    static let verificationCodeRecieved = Notification.Name("verificationCodeRecieved")
    
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var deviceToken: String?
    
    func continueIfVersionCheckPasses(application: UIApplication, continueWith: ((UIApplication) -> Void)? = nil) {
        VersioningService.sharedInstance.getIsVersionValid { [weak self] (_, result) in
            switch result {
            case .value(let boxedBool):
                if boxedBool.value {
                   continueWith?(application)
                } else {
                    let rootVC = self?.window?.rootViewController
                    let forceUpdateVC = F4SForceAppUpdateViewController()
                    rootVC?.present(forceUpdateVC, animated: true, completion: nil)
                }
            default:
                continueWith?(application)
            }
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        GMSServices.provideAPIKey(GoogleApiKeys.googleApiKey)
        GMSPlacesClient.provideAPIKey(GoogleApiKeys.googleApiKey)
        log.setup(level: .debug, showThreadName: true, showLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: nil, fileLevel: .debug)
        continueIfVersionCheckPasses(application: application, continueWith: versionAuthorizedToContinue)
        return true
    }
    
    func versionAuthorizedToContinue(_ application: UIApplication) {
        // create or re-register user
        UserService.sharedInstance.registerUser(completed: { [weak self] succeeded in
            if succeeded {
                self?.onUserConfirmedToExist(application: application)
            } else {
                log.debug("Couldn't create a user")
            }
        })
    }
    
    func onUserConfirmedToExist(application: UIApplication) {
       printDebugUserInfo()
        registerApplicationForRemoteNotifications(application)
        DatabaseService.sharedInstance.getLatestDatabase()
        guard let window = window else { return }
        let isFirstLaunch = UserDefaults.standard.value(forKey: UserDefaultsKeys.isFirstLaunch) as? Bool ?? true
        if isFirstLaunch {
            guard let ctrl = window.rootViewController?.topMostViewController as? OnboardingViewController else {
                return
            }
            ctrl.hideOnboardingControls = false
        } else {
            let navigationHelper = CustomNavigationHelper.sharedInstance
            if let shouldLoadTimeline = UserDefaults.standard.value(forKey: UserDefaultsKeys.shouldLoadTimeline) as? Bool {
                if shouldLoadTimeline {
                    navigationHelper.navigateToTimeline(threadUuid: nil)
                }
            } else {
                navigationHelper.navigateToMap()
                navigationHelper.mapViewController.shouldRequestAuthorization = false
            }
        }
    }
    
    func printDebugUserInfo() {
        print("********************************************************")
        print("Vendor id = \(UIDevice.current.identifierForVendor!)")
        let userIdKey = UserDefaultsKeys.userUuid
        let k = KeychainSwift()
        let userID = k.get(userIdKey)!
        print("User id = \(userID)")
        print("********************************************************")
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        guard let url = userActivity.webpageURL else {
            return false
        }
        // Handle being invoked from a universal link in safari running on the current device
        setInvokingUrl(url)
        return true
    }
    
    func setInvokingUrl(_ url: URL) {
        print("Invoked from url: \(url.absoluteString)")
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
        registerApplicationForRemoteNotifications(application)
        if let window = self.window {
            NotificationHelper.sharedInstance.updateToolbarButton(window: window)
        }
    }

    func applicationDidBecomeActive(_ appliction: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        continueIfVersionCheckPasses(application: appliction, continueWith: nil)
    }

    func applicationWillTerminate(_: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
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
            UserDefaults.standard.set(true, forKey: UserDefaultsKeys.didDeclineRemoteNotifications)
        }
    }
    
    func application(_: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        let token = tokenParts.joined()
        UserService.sharedInstance.enablePushNotificationForUser(withDeviceToken: token, putCompleted: { success, result in
            self.deviceToken = token
            if !success {
                var alert = UIAlertController(title: "Failed to enable push notification", message: "Server call failed", preferredStyle: UIAlertControllerStyle.actionSheet)
                
                CustomNavigationHelper.sharedInstance.topMostViewController()?.present(alert, animated: true, completion: nil)
                
            }
        })
    }
    
    func application(_: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        var alert = UIAlertController(title: "Failed to Register for push notifications", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        CustomNavigationHelper.sharedInstance.topMostViewController()?.present(alert, animated: true, completion: nil)
    }
    
    func application(_: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let appState = UIApplication.shared.applicationState
        if appState == .active {
            if let window = self.window {
                NotificationHelper.sharedInstance.handleRemoteNotification(userInfo: userInfo, window: window, isAppActive: true)
                NotificationHelper.sharedInstance.updateToolbarButton(window: window)
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
            print("Recieved remote notification")
        }
    }
    
    func registerApplicationForRemoteNotifications(_ application: UIApplication) {
        if application.isRegisteredForRemoteNotifications || (application.currentUserNotificationSettings?.types.contains(.alert))! {
            application.registerForRemoteNotifications()
        }
    }
}

