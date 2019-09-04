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
