
import Foundation
import WorkfinderCommon
import WorkfinderAppLogic

public class CoreInjection : CoreInjectionProtocol {
    public weak var appCoordinator: AppCoordinatorProtocol?
    public var launchOptions: LaunchOptions? = nil
    public var user: Candidate
    public var userRepository: UserRepositoryProtocol
    public var companyDownloadFileManager: F4SCompanyDownloadManagerProtocol
    public var log: F4SAnalyticsAndDebugging
    public let appInstallationLogic: AppInstallationLogicProtocol
    public let appSettings: AppSettingProvider
    public var userService: F4SUserServiceProtocol
    
    public init(launchOptions: LaunchOptions?,
                appInstallationLogic: AppInstallationLogicProtocol,
                user: Candidate,
                userService: F4SUserServiceProtocol,
                userRepository: UserRepositoryProtocol,
                companyDownloadFileManager: F4SCompanyDownloadManagerProtocol,
                log: F4SAnalyticsAndDebugging,
                appSettings: AppSettingProvider) {
        
        self.launchOptions = launchOptions
        self.appInstallationLogic = appInstallationLogic
        self.user = user
        self.userService = userService
        self.userRepository = userRepository
        self.companyDownloadFileManager = companyDownloadFileManager
        self.log = log
        self.appSettings = appSettings
    }
}
