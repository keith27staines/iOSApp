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
import WorkfinderCommon

let globalLog = XCGLogger.default

extension Notification.Name {
    static let verificationCodeRecieved = Notification.Name("verificationCodeRecieved")
}


class AppInstallationUuidLogic {
    let localStore: LocalStorageProtocol
    init(localStore: LocalStorageProtocol = LocalStore()) {
        self.localStore = localStore
    }
    var installationUuid: F4SUUID {
        var uuid = localStore.value(key: LocalStore.Key.installationUuid) as? F4SUUID
        if uuid == nil {
            uuid = UUID().uuidString
            localStore.setValue(uuid, for: LocalStore.Key.installationUuid)
        }
        return uuid!
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var appCoordinator: AppCoordinatorProtocol!
    var window: UIWindow?
    var deviceToken: String?

    public private (set) var databaseDownloadManager: F4SDatabaseDownloadManagerProtocol?
    
    var userService: F4SUserServiceProtocol = {
        return F4SUserService()
    }()
    
    lazy var appInstallationUuid = AppInstallationUuidLogic().installationUuid
    
    // MARK:- Application events
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if ProcessInfo.processInfo.arguments.contains("isUnitTesting") { return true }
        DataFixes().run()
        f4sLog = F4SLog()
        globalLog.debug("\n\n\n********\nWorkfinder launched in environement \(Config.ENVIRONMENT)\n********")
        databaseDownloadManager = F4SDatabaseDownloadManager()
        let appCoordinatorFactory = AppCoordinatoryFactory()
        appCoordinator = appCoordinatorFactory.makeAppCoordinator(
            registrar: application,
            launchOptions: launchOptions,
            installationUuid: appInstallationUuid,
            databaseDownloadManager: databaseDownloadManager!,
            f4sLog: f4sLog!)
        
        window = appCoordinator.window
        appCoordinator.start()
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
        f4sLog.updateHistory()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        self.saveContext()
    }
    
    func application(_: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        let token = tokenParts.joined()
        userService.enablePushNotificationForUser(installationUuid: appInstallationUuid, withDeviceToken: token) { (result) in
            switch result {
            case .error(let error):
                globalLog.error(error)
            case .success(_):
                globalLog.debug("Notifications enabled on server with token \(token)")
            }
        }
    }
    
    func application(_: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        globalLog.error("Failed to register with error \(error)")
    }
    
    // This method handles notifications arriving whether the app was running already or the notification opened the app
    func application(_: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        DispatchQueue.main.async {
            globalLog.debug("Received remote notification")
            UNService.shared.handleRemoteNotification(userInfo: userInfo)
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
                globalLog.severe(nserror)
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
                globalLog.error(nserror)
                assertionFailure("error saving to coredata context \(nserror)")
            }
        }
    }
}

// MARK: helpers
extension AppDelegate {
    
    func setInvokingUrl(_ url: URL) {
        globalLog.debug("Invoked from url: \(url.absoluteString)")
        guard let universalLink = UniversalLink(url: url) else { return }
        switch universalLink {
        case .recommendCompany(_):
            TabBarCoordinator.sharedInstance.navigateToRecommendations()

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

















