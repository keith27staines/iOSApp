
import WorkfinderCommon
import WorkfinderNetworking
import WorkfinderServices
import WorkfinderCoordinators
import WorkfinderAppLogic
import WorkfinderUserDetailsUseCase
import WorkfinderOnboardingUseCase
import WorkfinderCompanyDetailsUseCase
import WorkfinderUI
import WorkfinderVersionCheck
import UIKit

class MasterBuilder: TabbarCoordinatorFactoryProtocol {
    
    let workfinderEndpoint: WorkfinderEndpoint
    var log: F4SLog
    
    lazy var localStore: LocalStorageProtocol = {
        return LocalStore()
    }()
    
    lazy var userRepo: UserRepositoryProtocol = {
        return UserRepository(localStore: self.localStore)
    }()
    
    lazy var hostsProvider: HostsProviderProtocol = {
        return HostsProvider(networkConfig: self.networkConfiguration)
    }()
    
    lazy var associationsProvider: AssociationsServiceProtocol = {
        return AssociationsService(networkConfig: self.networkConfiguration)
    }()
    
    lazy var onboardingCoordinatorFactory: OnboardingCoordinatorFactoryProtocol = {
         return OnboardingCoordinatorFactory(localStore: self.localStore)
     }()
    
    let launchOptions: [UIApplication.LaunchOptionsKey : Any]?
    let apnsEnvironment: String = Config.apnsEnv
    let environment: EnvironmentType = Config.environment
    var baseUrlString: String { return Config.workfinderApiBase }
    
    init(launchOptions: [UIApplication.LaunchOptionsKey : Any]?) {
        self.launchOptions = launchOptions
        self.log = F4SLog()
        self.workfinderEndpoint = try! WorkfinderEndpoint(baseUrlString: Config.workfinderApiBase)
        onLaunched()
    }
    
    func makeTabBarCoordinator(parent: AppCoordinatorProtocol,
                               router: NavigationRoutingProtocol,
                               inject: CoreInjectionProtocol) -> TabBarCoordinatorProtocol {
        return TabBarCoordinator(
            parent: parent,
            navigationRouter: router,
            inject: inject,
            companyCoordinatorFactory: self.companyCoordinatorFactory
        )
    }
    
    func onLaunched() {
        let localStore = LocalStore()
        let isFirstLaunch = localStore.value(key: .isFirstLaunch) as? Bool ?? true
        if isFirstLaunch { log.track(.first_use) }
        log.track(.app_open)
    }
    
    lazy var appVersion: String = {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }()
    
    lazy var versionChecker: WorkfinderVersionChecker = {
        
        let versionChecker = WorkfinderVersionChecker(
            serverEnvironmentType: Config.environment,
            currentVersion: appVersion,
            networkConfig: self.networkConfiguration,
            log: self.log)
        return versionChecker
    }()
    
    lazy var networkConfiguration: NetworkConfig = {
        let sessionManager = F4SNetworkSessionManager(appVersion: appVersion)
        let endpoint = self.workfinderEndpoint
        let networkCallLogger = NetworkCallLogger(log: log)
        let networkConfig = NetworkConfig(logger: networkCallLogger,
                                          sessionManager: sessionManager,
                                          workfinderEndpoint: endpoint,
                                          userRepository: self.userRepo)
        return networkConfig
    }()
    
    lazy var rootNavigationController: UINavigationController = {
        let navigationController = UINavigationController(rootViewController: AppCoordinatorBackgroundViewController())
        navigationController.setNavigationBarHidden(true, animated: false)
        return navigationController
    }()
    
    lazy var rootNavigationRouter: NavigationRoutingProtocol = {
        return NavigationRouter(navigationController: self.rootNavigationController)
    }()
    
    lazy var injection: CoreInjectionProtocol = {
        return CoreInjection(
            launchOptions: self.launchOptions,
            networkConfig: self.networkConfiguration,
            versionChecker: self.versionChecker,
            user: self.userRepo.loadCandidate(),
            userRepository: self.userRepo,
            log: self.log
        )
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
    
    lazy var companyCoordinatorFactory: CompanyCoordinatorFactoryProtocol = {
        let applyService = PostPlacementService(networkConfig: self.networkConfiguration)
        return CompanyCoordinatorFactory(applyService: applyService,
                                         associationsProvider: self.associationsProvider,
                                         environment: environment
        )
    }()
    
    func buildAppCoordinator(suppressOnboarding: Bool) -> AppCoordinatorProtocol {
        return  AppCoordinator(
            navigationRouter: rootNavigationRouter,
            inject: injection,
            deviceRegistrar: nil,
            companyCoordinatorFactory: companyCoordinatorFactory,
            hostsProvider: hostsProvider,
            localStore: localStore,
            onboardingCoordinatorFactory: onboardingCoordinatorFactory,
            tabBarCoordinatorFactory: self,
            window: self.window,
            suppressOnboarding: suppressOnboarding)
    }

}
