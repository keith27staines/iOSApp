//
//  AppCoordinatorFactory.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 07/07/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation
import WorkfinderCommon
import WorkfinderAppLogic

protocol AppCoordinatoryFactoryProtocol {}

struct AppCoordinatoryFactory : AppCoordinatoryFactoryProtocol {
    
    func makeAppCoordinator(
        registrar: RemoteNotificationsRegistrarProtocol,
        launchOptions: LaunchOptions? = nil,
        appInstallationUuidLogic: AppInstallationUuidLogic,
        user: F4SUserProtocol = F4SUser(),
        userService: F4SUserServiceProtocol = F4SUserService(),
        userRepository: F4SUserRepositoryProtocol = F4SUserRepository(),
        databaseDownloadManager: F4SDatabaseDownloadManagerProtocol = F4SDatabaseDownloadManager(),
        navigationRouter: NavigationRoutingProtocol = NavigationRouter(navigationController: UINavigationController(rootViewController: AppCoordinatorBackgroundViewController())),
        f4sLog: F4SAnalyticsAndDebugging
        ) -> AppCoordinatorProtocol {
        
        let injection = CoreInjection(
            launchOptions: launchOptions,
            appInstallationUuidLogic: appInstallationUuidLogic,
            user: user,
            userService: userService,
            userRepository: userRepository,
            databaseDownloadManager: databaseDownloadManager,
            f4sLog: f4sLog)
        
        let versionCheckCoordinator = VersionCheckCoordinator(parent: nil, navigationRouter: navigationRouter)
        versionCheckCoordinator.versionCheckService = F4SWorkfinderVersioningService()
        
        return AppCoordinator(versionCheckCoordinator: versionCheckCoordinator,
                              registrar: registrar,
                              navigationRouter: navigationRouter,
                              inject: injection)
    }
}
