
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
    public var networkConfig: NetworkConfig
    
    public init(launchOptions: LaunchOptions?,
                networkConfig: NetworkConfig,
                appInstallationLogic: AppInstallationLogicProtocol,
                user: Candidate,
                userRepository: UserRepositoryProtocol,
                companyDownloadFileManager: F4SCompanyDownloadManagerProtocol,
                log: F4SAnalyticsAndDebugging) {
        
        self.launchOptions = launchOptions
        self.networkConfig = networkConfig
        self.appInstallationLogic = appInstallationLogic
        self.user = user
        self.userRepository = userRepository
        self.companyDownloadFileManager = companyDownloadFileManager
        self.log = log
    }
}
