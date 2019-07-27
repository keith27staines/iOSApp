//
//  CoreInjection.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 21/02/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation
import WorkfinderCommon
import WorkfinderNetworking
import WorkfinderServices
import WorkfinderAppLogic

public typealias LaunchOptions = [UIApplication.LaunchOptionsKey: Any]

protocol CoreInjectionProtocol : class {
    var appInstallationUuidLogic: AppInstallationUuidLogic { get }
    var launchOptions: LaunchOptions? { get set }
    var user: F4SUserProtocol { get set }
    var userService: F4SUserServiceProtocol { get }
    var userStatusService: F4SUserStatusServiceProtocol { get }
    var userRepository: F4SUserRepositoryProtocol { get }
    var databaseDownloadManager: F4SDatabaseDownloadManagerProtocol { get }
    var log: F4SAnalyticsAndDebugging { get }
}

class CoreInjection : CoreInjectionProtocol {
    
    var launchOptions: LaunchOptions? = nil
    var user: F4SUserProtocol
    var userService: F4SUserServiceProtocol
    var userStatusService: F4SUserStatusServiceProtocol
    var userRepository: F4SUserRepositoryProtocol
    var databaseDownloadManager: F4SDatabaseDownloadManagerProtocol
    var log: F4SAnalyticsAndDebugging
    let appInstallationUuidLogic: AppInstallationUuidLogic
    
    init(launchOptions: LaunchOptions?,
         appInstallationUuidLogic: AppInstallationUuidLogic,
         user: F4SUserProtocol,
         userService: F4SUserServiceProtocol,
         userStatusService: F4SUserStatusServiceProtocol = F4SUserStatusService.shared,
         userRepository: F4SUserRepositoryProtocol,
         databaseDownloadManager: F4SDatabaseDownloadManagerProtocol,
         tabBarFactory: @escaping (() -> Coordinating) = { return TabBarCoordinator.sharedInstance },
         f4sLog: F4SAnalyticsAndDebugging) {
        
        self.launchOptions = launchOptions
        self.user = user
        self.userService = userService
        self.userStatusService = userStatusService
        self.userRepository = userRepository
        self.databaseDownloadManager = databaseDownloadManager
        self.log = f4sLog
        self.appInstallationUuidLogic = appInstallationUuidLogic
    }
}
