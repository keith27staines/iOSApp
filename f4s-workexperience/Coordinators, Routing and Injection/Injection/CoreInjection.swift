//
//  CoreInjection.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 21/02/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation

public typealias LaunchOptions = [UIApplication.LaunchOptionsKey: Any]

protocol CoreInjectionProtocol : class {
    var installationUuid: F4SUUID { get }
    var launchOptions: LaunchOptions? { get set }
    var user: F4SUserProtocol { get set }
    var userService: F4SUserServiceProtocol { get }
    var databaseDownloadManager: F4SDatabaseDownloadManagerProtocol { get }
    var log: F4SAnalyticsAndDebugging { get }
}

class CoreInjection : CoreInjectionProtocol {
    
    var launchOptions: LaunchOptions? = nil
    var user: F4SUserProtocol = F4SUser()
    var userService: F4SUserServiceProtocol = F4SUserService()
    var databaseDownloadManager: F4SDatabaseDownloadManagerProtocol = F4SDatabaseDownloadManager()
    var log: F4SAnalyticsAndDebugging
    let installationUuid: F4SUUID
    
    init(launchOptions: LaunchOptions?,
         installationUuid: F4SUUID,
         user: F4SUserProtocol,
         userService: F4SUserServiceProtocol,
         databaseDownloadManager: F4SDatabaseDownloadManagerProtocol,
         tabBarFactory: @escaping (() -> Coordinating) = { return TabBarCoordinator.sharedInstance },
         f4sLog: F4SAnalyticsAndDebugging) {
        
        self.launchOptions = launchOptions
        self.user = user
        self.userService = userService
        self.databaseDownloadManager = databaseDownloadManager
        self.log = f4sLog
        self.installationUuid = installationUuid
    }
}
