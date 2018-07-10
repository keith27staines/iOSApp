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
import Analytics
import Segment_Bugsnag

let log = XCGLogger.default

extension Notification.Name {
    
    static let verificationCodeRecieved = Notification.Name("verificationCodeRecieved")
    
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var deviceToken: String?

    public private (set) var databaseDownloadManager: F4SDatabaseDownloadManager?
    lazy var userService: F4SUserServiceProtocol = {
        return F4SUserService()
    }()
    
    // MARK:- Application events
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        if ProcessInfo.processInfo.arguments.contains("isUnitTesting") {
            print("Exiting didFinishLaunchingWithOptions early because `isUnitTesting` argument is set")
            return true
        }
        f4sLog = F4SLog()

        log.debug("\n\n\n**************\nWorkfinder launched in environement \(Config.ENVIRONMENT)\n**************")
        GMSServices.provideAPIKey(GoogleApiKeys.googleApiKey)
        GMSPlacesClient.provideAPIKey(GoogleApiKeys.googleApiKey)
        
        registerUser(application: application)
        return true
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
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        // Handle being invoked from a smart banner somewhere out there on the web
        setInvokingUrl(url)
        return true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        registerApplicationForRemoteNotifications(application)
    }
    
    func applicationDidBecomeActive(_ appliction: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
        debug?.updateHistory()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        self.saveContext()
    }
    
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

    // MARK:- Handle restoration of background session
    func application(_ application: UIApplication,
                     handleEventsForBackgroundURLSession identifier: String,
                     completionHandler: @escaping () -> Void) {
        databaseDownloadManager = F4SDatabaseDownloadManager(backgroundSessionCompletionHandler: completionHandler)
        databaseDownloadManager?.start()
    }
    
    // MARK: - Setup CoreData
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "f4s-workexperience")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let nserror = error as NSError? {
                log.severe(nserror)
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
                log.error(nserror)
                assertionFailure("error saving to coredata context \(nserror)")
            }
        }
    }
}


// MARK: helpers
extension AppDelegate {
    
    func registerApplicationForRemoteNotifications(_ application: UIApplication) {
        if application.isRegisteredForRemoteNotifications || (application.currentUserNotificationSettings?.types.contains(.alert))! {
            application.registerForRemoteNotifications()
        }
    }
    
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
    
    func registerUser(application: UIApplication) {
        userService.registerAnonymousUserOnServer { [weak self] (result) in
            DispatchQueue.main.async {
                guard let strongSelf = self else { return }
                switch result {
                case .error(let error):
                    print(error)
                    if strongSelf.userService.hasAccount() {
                        // couldn't register user but user has registered before so ok to continue
                        strongSelf.onUserAccountConfirmedToExist(application: application)
                    } else {
                        log.debug("Couldn't register user, offering retry")
                        strongSelf.presentNoNetworkMustRetry(application: application, retryOperation: { [weak self] (application) in
                            self?.registerUser(application: application)
                        })
                    }
                case .success(let result):
                    let keychain = KeychainSwift()
                    let currentUserUuid = keychain.get(UserDefaultsKeys.userUuid)
                    let anonymousUserUuid = result.uuid
                    if currentUserUuid == nil && anonymousUserUuid != nil {
                        log.debug("Using anonymous user id")
                        keychain.set(anonymousUserUuid!, forKey: UserDefaultsKeys.userUuid)
                        SEGAnalytics.shared().identify(anonymousUserUuid!)
                    } else {
                        log.debug("Using user id from keychain")
                    }
                    strongSelf.onUserAccountConfirmedToExist(application: application)
                }
            }
        }
    }
    
    func onUserAccountConfirmedToExist(application: UIApplication) {
        printDebugUserInfo()
        let userId = F4SUser.userUuidFromKeychain()
        SEGAnalytics.shared().identify(userId!)
        _ = F4SNetworkSessionManager.shared
        F4SUserStatusService.shared.beginStatusUpdate()
        if databaseDownloadManager == nil {
            databaseDownloadManager = F4SDatabaseDownloadManager()
        }
        registerApplicationForRemoteNotifications(application)
        databaseDownloadManager?.start()
        let isFirstLaunch = UserDefaults.standard.value(forKey: UserDefaultsKeys.isFirstLaunch) as? Bool ?? true
        if isFirstLaunch {
            guard let ctrl = window?.rootViewController?.topMostViewController as? OnboardingViewController else {
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
    
    func printDebugUserInfo() {
        log.debug("***************")
        log.debug("Vendor id = \(UIDevice.current.identifierForVendor!)")
        let userIdKey = UserDefaultsKeys.userUuid
        let k = KeychainSwift()
        let userID = k.get(userIdKey)!
        log.debug("User id = \(userID)")
        log.debug("***************")
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
}

