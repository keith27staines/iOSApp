
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
    public var versionChecker: WorkfinderEnvironmentConsistencyCheckerProtocol
    public var requestAppReviewLogic: RequestAppReviewLogic
    
    public init(launchOptions: LaunchOptions?,
                networkConfig: NetworkConfig,
                versionChecker: WorkfinderEnvironmentConsistencyCheckerProtocol,
                user: Candidate,
                requestAppReviewLogic: RequestAppReviewLogic,
                userRepository: UserRepositoryProtocol,
                log: F4SAnalyticsAndDebugging
    ) {
        
        self.launchOptions = launchOptions
        self.networkConfig = networkConfig
        self.versionChecker = versionChecker
        self.user = user
        self.requestAppReviewLogic = requestAppReviewLogic
        self.userRepository = userRepository
        self.log = log
    }
}
