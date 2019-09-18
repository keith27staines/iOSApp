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
import WorkfinderNetworking
import WorkfinderServices
import WorkfinderCoordinators
import WorkfinderAppLogic
import WorkfinderUserDetailsUseCase

let globalLog = XCGLogger.default
public var f4sLog: F4SAnalyticsAndDebugging!

class MasterBuilder {
    let launchOptions: [UIApplication.LaunchOptionsKey : Any]?
    let localStore: LocalStore
    let userRepo: F4SUserRepository
    let databaseDownloadManager: F4SDatabaseDownloadManager
    let log: F4SAnalyticsAndDebugging
    let registrar: RemoteNotificationsRegistrarProtocol

    lazy var networkConfiguration: NetworkConfig = {
        let wexApiKey = Config.wexApiKey
        let baseUrlString = Config.workfinderApiBase
        let sessionManager = F4SNetworkSessionManager(wexApiKey: wexApiKey)
        let endpoints = WorkfinderEndpoint(baseUrlString: baseUrlString)
        let networkCallLogger = NetworkCallLogger(log: f4sLog)
        let networkConfig = NetworkConfig(workfinderApiKey: wexApiKey,
                                          logger: networkCallLogger,
                                          sessionManager: sessionManager,
                                          endpoints: endpoints)
        return networkConfig
    }()
    
    lazy var appInstallationUuidLogic: AppInstallationUuidLogic = {
        let userRepo = F4SUserRepository(localStore: localStore)
        let userService = makeUserService()
        let registerDeviceService = makeDeviceRegistrationService()
        return AppInstallationUuidLogic(userService: userService,
                                        userRepo: userRepo,
                                        apnsEnvironment: Config.apnsEnv,
                                        registerDeviceService: registerDeviceService)
    }()
    
    init(registrar: RemoteNotificationsRegistrarProtocol, launchOptions: [UIApplication.LaunchOptionsKey : Any]?) {
        self.localStore = LocalStore()
        self.userRepo = F4SUserRepository(localStore: localStore)
        self.launchOptions = launchOptions
        self.log = F4SLog()
        self.databaseDownloadManager = F4SDatabaseDownloadManager()
    }
    
    func build() {
        networkConfiguration = makeNetworkConfiguration(wexApiKey: , baseUrlString: Config.workfinderApiBase)
    }
    
    func makeUserService() -> F4SUserServiceProtocol {
        return F4SUserService(configuration: networkConfiguration)
    }
    
    func makeUserStatusService() -> F4SUserStatusServiceProtocol {
        return F4SUserStatusService(configuration: networkConfiguration)
    }
    
    func makeDeviceRegistrationService() -> F4SDeviceRegistrationServiceProtocol {
        return F4SDeviceRegistrationService(configuration: networkConfiguration)
    }
    
    func makeContentService() -> F4SContentServiceProtocol {
        return F4SContentService(configuration: networkConfiguration)
    }
    
    func makeVersionCheckService() -> F4SWorkfinderVersioningService {
        return F4SWorkfinderVersioningService(configuration: networkConfiguration)
    }
    
    lazy var appCoordinator: AppCoordinator = {
        let networkConfiguration = self.networkConfiguration
        let navigationController = UINavigationController(rootViewController: AppCoordinatorBackgroundViewController())
        let navigationRouter = NavigationRouter(navigationController: navigationController)
        let userRepo = self.userRepo
        let userService = self.makeUserService()
        let userStatusService = self.makeUserStatusService()
        let databaseDownloadManager = self.databaseDownloadManager
        let contentService = self.makeContentService()
        let versionCheckService = makeVersionCheckService()
        let injection = CoreInjection(
            launchOptions: launchOptions,
            appInstallationUuidLogic: appInstallationUuidLogic,
            user: userRepo.load(),
            userService: userService,
            userStatusService: userStatusService,
            userRepository: userRepo,
            databaseDownloadManager: databaseDownloadManager,
            contentService: contentService,
            f4sLog: log)
        let versionCheckCoordinator = VersionCheckCoordinator(parent: nil, navigationRouter: navigationRouter)
        versionCheckCoordinator.versionCheckService = versionCheckService
        
        return AppCoordinator(versionCheckCoordinator: versionCheckCoordinator,
                              registrar: registrar,
                              navigationRouter: navigationRouter,
                              inject: injection)
    }()

}


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var deviceToken: String?
    var masterBuilder: MasterBuilder!
    
    lazy var userService: F4SUserServiceProtocol = {
        return self.masterBuilder.makeUserService()
    }()
    
    // MARK:- Application events
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Prevent the entire application being built if we are just running unit tests
        if ProcessInfo.processInfo.arguments.contains("isUnitTesting") { return true }
 
        DataFixes().run()
        masterBuilder = MasterBuilder(registrar: self, launchOptions: launchOptions)
        f4sLog = masterBuilder.log
        let appCoordinator = masterBuilder.appCoordinator
        window = appCoordinator.window
        appCoordinator.start()
        return true
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
        f4sLog.updateHistory()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        self.saveContext()
    }
    
    func application(_: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        guard let appInstallationUuid = appInstallationUuidLogic.registeredInstallationUuid else { return }
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

















