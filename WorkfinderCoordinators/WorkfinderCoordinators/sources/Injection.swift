
import Foundation
import WorkfinderCommon
import WorkfinderAppLogic

public class CoreInjection : CoreInjectionProtocol {
    public weak var appCoordinator: AppCoordinatorProtocol?
    public var launchOptions: LaunchOptions? = nil
    public var user: Candidate
    public var userRepository: UserRepositoryProtocol
    public var log: F4SAnalyticsAndDebugging
    public var networkConfig: NetworkConfig
    public var versionChecker: WorkfinderVersionCheckerProtocol
    
    public init(launchOptions: LaunchOptions?,
                networkConfig: NetworkConfig,
                versionChecker: WorkfinderVersionCheckerProtocol,
                user: Candidate,
                userRepository: UserRepositoryProtocol,
                log: F4SAnalyticsAndDebugging) {
        
        self.launchOptions = launchOptions
        self.networkConfig = networkConfig
        self.versionChecker = versionChecker
        self.user = user
        self.userRepository = userRepository
        self.log = log
    }
}
