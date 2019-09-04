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
import WorkfinderCoordinators

public class CoreInjection : CoreInjectionProtocol {
    
    public var launchOptions: LaunchOptions? = nil
    public var user: F4SUserProtocol
    public var userService: F4SUserServiceProtocol
    public var userStatusService: F4SUserStatusServiceProtocol
    public var userRepository: F4SUserRepositoryProtocol
    public var databaseDownloadManager: F4SDatabaseDownloadManagerProtocol
    public var log: F4SAnalyticsAndDebugging
    public let appInstallationUuidLogic: AppInstallationUuidLogic
    
    public init(launchOptions: LaunchOptions?,
                appInstallationUuidLogic: AppInstallationUuidLogic,
                user: F4SUserProtocol,
                userService: F4SUserServiceProtocol,
                userStatusService: F4SUserStatusServiceProtocol = F4SUserStatusService.shared,
                userRepository: F4SUserRepositoryProtocol,
                databaseDownloadManager: F4SDatabaseDownloadManagerProtocol,
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
