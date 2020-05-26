
import WorkfinderCommon
import WorkfinderNetworking
import WorkfinderServices
import WorkfinderCoordinators
import WorkfinderAppLogic
import WorkfinderUserDetailsUseCase
import WorkfinderOnboardingUseCase
import WorkfinderCompanyDetailsUseCase
import WorkfinderUI
import UIKit

class MasterBuilder: TabbarCoordinatorFactoryProtocol {
    func makeTabBarCoordinator(parent: Coordinating,
                               router: NavigationRoutingProtocol,
                               inject: CoreInjectionProtocol) -> TabBarCoordinatorProtocol {
        return TabBarCoordinator(
            parent: parent,
            navigationRouter: router,
            inject: inject,
            companyCoordinatorFactory: self.companyCoordinatorFactory,
            interestsRepository: interestsRepository)
    }
    
    let launchOptions: [UIApplication.LaunchOptionsKey : Any]?
    let registrar: RemoteNotificationsRegistrarProtocol
    let apnsEnvironment: String = Config.apnsEnv
    let environment: EnvironmentType = Config.environment
    var baseUrlString: String { return Config.workfinderApiBase }
    
    init(registrar: RemoteNotificationsRegistrarProtocol,
         launchOptions: [UIApplication.LaunchOptionsKey : Any]?) {
        self.registrar = registrar
        self.launchOptions = launchOptions
        self.log = F4SLog()
        self.workfinderEndpoint = try! WorkfinderEndpoint(baseUrlString: Config.workfinderApiBase)
    }
    
    let workfinderEndpoint: WorkfinderEndpoint
    
    lazy var networkConfiguration: NetworkConfig = {
        let sessionManager = F4SNetworkSessionManager()
        let endpoint = self.workfinderEndpoint
        let networkCallLogger = NetworkCallLogger(log: log)
        let networkConfig = NetworkConfig(logger: networkCallLogger,
                                          sessionManager: sessionManager,
                                          workfinderEndpoint: endpoint,
                                          userRepository: self.userRepo)
        return networkConfig
    }()
    
    lazy var rootNavigationController: UINavigationController = {
        return UINavigationController(rootViewController: AppCoordinatorBackgroundViewController())
    }()
    
    lazy var rootNavigationRouter: NavigationRoutingProtocol = {
        return NavigationRouter(navigationController: self.rootNavigationController)
    }()
    
    lazy var appInstallationLogic: AppInstallationLogicProtocol = {
        return AppInstallationLogic(localStore: self.localStore)
    }()
    
    lazy var injection: CoreInjectionProtocol = {
        return CoreInjection(
            launchOptions: self.launchOptions,
            networkConfig: self.networkConfiguration,
            appInstallationLogic: self.appInstallationLogic,
            user: self.userRepo.loadCandidate(),
            userRepository: self.userRepo,
            companyDownloadFileManager: self.companyFileDownloadManager,
            log: self.log)
    }()
    
    lazy var window: UIWindow = {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = rootNavigationRouter.rootViewController
        window.makeKeyAndVisible()
        if #available(iOS 13.0, *) {
            if window.responds(to: #selector(getter: UIView.overrideUserInterfaceStyle)) {
                window.setValue(UIUserInterfaceStyle.light.rawValue, forKey: "overrideUserInterfaceStyle")
            }
        }
        return window
    }()
    
    func buildAppCoordinator() -> AppCoordinatorProtocol {
        return  AppCoordinator(registrar: registrar,
                              navigationRouter: rootNavigationRouter,
                              inject: injection,
                              companyCoordinatorFactory: companyCoordinatorFactory,
                              hostsProvider: hostsProvider,
                              localStore: localStore,
                              onboardingCoordinatorFactory: onboardingCoordinatorFactory,
                              tabBarCoordinatorFactory: self,
                              window: self.window)
    }
    
    lazy var companyCoordinatorFactory: CompanyCoordinatorFactoryProtocol = {
        let applyService = PostPlacementService(networkConfig: self.networkConfiguration)
        return CompanyCoordinatorFactory(applyService: applyService,
                                         associationsProvider: self.associationsProvider,
                                         environment: environment,
                                         interestsRepository: interestsRepository)
    }()
    
    var log: F4SAnalyticsAndDebugging
    
    lazy var localStore: LocalStorageProtocol = {
        return LocalStore()
    }()
    
    lazy var userRepo: UserRepositoryProtocol = {
        return UserRepository(localStore: self.localStore)
    }()
    
    lazy var companyFileDownloadManager: F4SCompanyDownloadManagerProtocol = {
        return F4SCompanyDownloadManager()
    }()
    
    lazy var hostsProvider: HostsProviderProtocol = {
        return HostsProvider(networkConfig: self.networkConfiguration)
    }()
    
    lazy var associationsProvider: HostLocationAssociationsServiceProtocol = {
        return HostLocationAssociationsService(networkConfig: self.networkConfiguration)
    }()
    
    lazy var interestsRepository: F4SSelectedInterestsRepositoryProtocol = {
        return F4SSelectedInterestsRepository(localStore: self.localStore)
    }()
    
    lazy var onboardingCoordinatorFactory: OnboardingCoordinatorFactoryProtocol = {
         return OnboardingCoordinatorFactory(localStore: self.localStore)
     }()

}
