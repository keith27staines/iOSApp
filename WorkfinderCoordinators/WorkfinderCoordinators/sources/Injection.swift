import Foundation
import WorkfinderCommon
import WorkfinderServices
import WorkfinderAppLogic

public typealias LaunchOptions = [UIApplication.LaunchOptionsKey: Any]

public protocol CoreInjectionProtocol : class {
    var appInstallationUuidLogic: AppInstallationUuidLogic { get }
    var launchOptions: LaunchOptions? { get set }
    var user: F4SUserProtocol { get set }
    var userService: F4SUserServiceProtocol { get }
    var userStatusService: F4SUserStatusServiceProtocol { get }
    var userRepository: F4SUserRepositoryProtocol { get }
    var databaseDownloadManager: F4SDatabaseDownloadManagerProtocol { get }
    var log: F4SAnalyticsAndDebugging { get }
}

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
