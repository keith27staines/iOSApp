import Foundation
import WorkfinderCommon
import WorkfinderServices
import WorkfinderAppLogic



public class CoreInjection : CoreInjectionProtocol {
    
    public var launchOptions: LaunchOptions? = nil
    public var user: F4SUser
    public var userService: F4SUserServiceProtocol
    public var userStatusService: F4SUserStatusServiceProtocol
    public var userRepository: F4SUserRepositoryProtocol
    public var databaseDownloadManager: F4SDatabaseDownloadManagerProtocol
    public var log: F4SAnalyticsAndDebugging
    public let appInstallationUuidLogic: AppInstallationUuidLogicProtocol
    
    public init(launchOptions: LaunchOptions?,
                appInstallationUuidLogic: AppInstallationUuidLogic,
                user: F4SUser,
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
