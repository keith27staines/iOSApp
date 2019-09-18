
import WorkfinderCommon
import WorkfinderNetworking
import WorkfinderServices
import WorkfinderAppLogic
import WorkfinderUI

class MasterBuilder {
    let launchOptions: [UIApplication.LaunchOptionsKey : Any]?
    let localStore: LocalStore
    let userRepo: F4SUserRepository
    let databaseDownloadManager: F4SDatabaseDownloadManager
    let log: F4SAnalyticsAndDebugging
    let registrar: RemoteNotificationsRegistrarProtocol

    lazy var networkConfiguration: NetworkConfig = {
        let wexApiKey = Config.wexApiKey
        let baseUrlString = Config.workfinderApiBase
        let sessionManager = F4SNetworkSessionManager(wexApiKey: wexApiKey)
        let endpoints = WorkfinderEndpoint(baseUrlString: baseUrlString)
        let networkCallLogger = NetworkCallLogger(log: f4sLog)
        let networkConfig = NetworkConfig(workfinderApiKey: wexApiKey,
                                          logger: networkCallLogger,
                                          sessionManager: sessionManager,
                                          endpoints: endpoints)
        return networkConfig
    }()
    
    lazy var appInstallationUuidLogic: AppInstallationUuidLogic = {
        let userRepo = F4SUserRepository(localStore: localStore)
        let userService = makeUserService()
        let registerDeviceService = makeDeviceRegistrationService()
        return AppInstallationUuidLogic(userService: userService,
                                        userRepo: userRepo,
                                        apnsEnvironment: Config.apnsEnv,
                                        registerDeviceService: registerDeviceService)
    }()
    
    init(registrar: RemoteNotificationsRegistrarProtocol, launchOptions: [UIApplication.LaunchOptionsKey : Any]?) {
        self.localStore = LocalStore()
        self.userRepo = F4SUserRepository(localStore: localStore)
        self.launchOptions = launchOptions
        self.log = F4SLog()
        self.databaseDownloadManager = F4SDatabaseDownloadManager()
    }
    
    func build() {
        networkConfiguration = makeNetworkConfiguration(wexApiKey: , baseUrlString: Config.workfinderApiBase)
    }
    
    func makeUserService() -> F4SUserServiceProtocol {
        return F4SUserService(configuration: networkConfiguration)
    }
    
    func makeUserStatusService() -> F4SUserStatusServiceProtocol {
        return F4SUserStatusService(configuration: networkConfiguration)
    }
    
    func makeDeviceRegistrationService() -> F4SDeviceRegistrationServiceProtocol {
        return F4SDeviceRegistrationService(configuration: networkConfiguration)
    }
    
    func makeContentService() -> F4SContentServiceProtocol {
        return F4SContentService(configuration: networkConfiguration)
    }
    
    func makeVersionCheckService() -> F4SWorkfinderVersioningService {
        return F4SWorkfinderVersioningService(configuration: networkConfiguration)
    }
    
    lazy var appCoordinator: AppCoordinator = {
        let networkConfiguration = self.networkConfiguration
        let navigationController = UINavigationController(rootViewController: AppCoordinatorBackgroundViewController())
        let navigationRouter = NavigationRouter(navigationController: navigationController)
        let userRepo = self.userRepo
        let userService = self.makeUserService()
        let userStatusService = self.makeUserStatusService()
        let databaseDownloadManager = self.databaseDownloadManager
        let contentService = self.makeContentService()
        let versionCheckService = makeVersionCheckService()
        let injection = CoreInjection(
            launchOptions: launchOptions,
            appInstallationUuidLogic: appInstallationUuidLogic,
            user: userRepo.load(),
            userService: userService,
            userStatusService: userStatusService,
            userRepository: userRepo,
            databaseDownloadManager: databaseDownloadManager,
            contentService: contentService,
            f4sLog: log)
        let versionCheckCoordinator = VersionCheckCoordinator(parent: nil, navigationRouter: navigationRouter)
        versionCheckCoordinator.versionCheckService = versionCheckService
        
        return AppCoordinator(versionCheckCoordinator: versionCheckCoordinator,
                              registrar: registrar,
                              navigationRouter: navigationRouter,
                              inject: injection)
    }()

}
