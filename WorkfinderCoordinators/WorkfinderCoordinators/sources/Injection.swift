
import Foundation
import WorkfinderCommon
import WorkfinderAppLogic

public class CoreInjection : CoreInjectionProtocol {
    
    public weak var appCoordinator: AppCoordinatorProtocol?
    public var launchOptions: LaunchOptions? = nil
    public var user: F4SUser
    public var userService: F4SUserServiceProtocol
    public var userStatusService: F4SUserStatusServiceProtocol
    public var userRepository: F4SUserRepositoryProtocol
    public var databaseDownloadManager: F4SDatabaseDownloadManagerProtocol
    public var log: F4SAnalyticsAndDebugging
    public let appInstallationUuidLogic: AppInstallationUuidLogicProtocol
    public let contentService: F4SContentServiceProtocol
    public let appSettings: AppSettingProvider
    
    public init(launchOptions: LaunchOptions?,
                appInstallationUuidLogic: AppInstallationUuidLogicProtocol,
                user: F4SUser,
                userService: F4SUserServiceProtocol,
                userStatusService: F4SUserStatusServiceProtocol,
                userRepository: F4SUserRepositoryProtocol,
                databaseDownloadManager: F4SDatabaseDownloadManagerProtocol,
                contentService: F4SContentServiceProtocol,
                log: F4SAnalyticsAndDebugging,
                appSettings: AppSettingProvider) {
        
        self.launchOptions = launchOptions
        self.appInstallationUuidLogic = appInstallationUuidLogic
        self.user = user
        self.userService = userService
        self.userStatusService = userStatusService
        self.userRepository = userRepository
        self.databaseDownloadManager = databaseDownloadManager
        self.contentService = contentService
        self.log = log
        self.appSettings = appSettings
    }
}
