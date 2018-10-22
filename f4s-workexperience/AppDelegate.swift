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
    
    lazy var skins: Skins = Skin.loadSkins()
    
    lazy var skin: Skin? = {
        let workfinderSkin = skins["workfinder"]
        guard let partner = F4SPartnersModel.sharedInstance.selectedPartner else {
            return workfinderSkin
        }
        let partnerSkinKey = partner.name.lowercased()
        return skins[partnerSkinKey] ?? workfinderSkin
    }()
    
    // MARK:- Application events
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if ProcessInfo.processInfo.arguments.contains("isUnitTesting") {
            print("Exiting didFinishLaunchingWithOptions early because `isUnitTesting` argument is set")
            return true
        }
        f4sLog = F4SLog()
        log.debug("\n\n\n********\nWorkfinder launched in environement \(Config.ENVIRONMENT)\n********")
        GMSServices.provideAPIKey(GoogleApiKeys.googleApiKey)
        GMSPlacesClient.provideAPIKey(GoogleApiKeys.googleApiKey)
        if let userUuid = F4SUser.userUuidFromKeychain  {
            // Existing user
            log.debug("\nUsing existing user uuid from keychain")
            onUserConfirmedToHaveUuid(application: application, userUuid: userUuid)
        } else {
            // New user
            log.debug("\nRegistering new user to obtain anonymous uuid")
            registerNewUser(application: application, completion: { [weak self] userUuid in
                self?.onUserConfirmedToHaveUuid(application: application, userUuid: userUuid)
            })
        }
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
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
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        // Handle being invoked from a smart banner somewhere out there on the web
        setInvokingUrl(url)
        return true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
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
    
    func application(_: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        let token = tokenParts.joined()
        userService.enablePushNotificationForUser(withDeviceToken: token) { (result) in
            switch result {
            case .error(let error):
                log.error(error)
            default: break
            }
        }
    }
    
    func application(_: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        log.error("Failed to register with error \(error)")
    }
    
    func application(_: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        DispatchQueue.main.async {
            let appState = UIApplication.shared.applicationState
            if let window = self.window {
                UNService.shared.handleRemoteNotification(userInfo: userInfo, window: window, isAppActive: appState == .active)
            }
            completionHandler(UIBackgroundFetchResult.newData)
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
    
//    func registerApplicationForRemoteNotifications(_ application: UIApplication) {
//        UNService.shared.registerForRemoteNotifications()
//    }
    
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
    
    func registerNewUser(application: UIApplication, completion: @escaping (F4SUUID)->()) {
        userService.registerAnonymousUserOnServer { [weak self] (result) in
            DispatchQueue.main.async {
                guard let strongSelf = self else { return }
                switch result {
                case .error(let error):
                    log.debug("Couldn't register user, offering retry \(error)")
                    strongSelf.presentNoNetworkMustRetry(application: application, retryOperation: { [weak self] (application) in
                        self?.registerNewUser(application: application, completion: completion)
                    })
                case .success(let result):
                    guard let anonymousUserUuid = result.uuid else {
                        log.severe("anonyous user uuid is nil")
                        return
                    }
                    log.debug("Using anonymous user id \(anonymousUserUuid)")
                    SEGAnalytics.shared().identify(anonymousUserUuid)
                    completion(anonymousUserUuid)
                }
            }
        }
    }
    
    func onUserConfirmedToHaveUuid(application: UIApplication, userUuid: F4SUUID) {
        if userUuid != F4SUser.userUuidFromKeychain {
            F4SUser.setUserUuid(userUuid)
        }
        printDebugUserInfo()
        SEGAnalytics.shared().identify(userUuid)
        _ = F4SNetworkSessionManager.shared
        F4SUserStatusService.shared.beginStatusUpdate()
        if databaseDownloadManager == nil {
            databaseDownloadManager = F4SDatabaseDownloadManager()
        }
        application.registerForRemoteNotifications()
        databaseDownloadManager?.start()
        let isFirstLaunch = UserDefaults.standard.value(forKey: UserDefaultsKeys.isFirstLaunch) as? Bool ?? true
        if isFirstLaunch {
            guard let ctrl = window?.rootViewController?.topMostViewController as? OnboardingViewController else {
                assertionFailure("The root view controller is not an OnboardingViewController")
                return
            }
            UserDefaults.standard.set(false, forKey: UserDefaultsKeys.shouldLoadTimeline)
            _ = ctrl.view
            ctrl.hideOnboardingControls = false
        } else {
            CustomNavigationHelper.sharedInstance.navigateToMostAppropriateInitialTab()
        }
    }
    
    func printDebugUserInfo() {
        let info = """
                   ***************
                   Vendor id = \(UIDevice.current.identifierForVendor?.uuidString ?? "nil")
                   User id = \(F4SUser.userUuidFromKeychain ?? "nil user")
                   ***************
                   """
        log.debug("\n\(info)")
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
















