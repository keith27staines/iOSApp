
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
            companyCoordinatorFactory: companyCoordinatorFactory,
            documentUploaderFactory: documentUploaderFactory,
            interestsRepository: interestsRepository,
            roleService: roleService)
    }
    
    let launchOptions: [UIApplication.LaunchOptionsKey : Any]?
    let registrar: RemoteNotificationsRegistrarProtocol
    let apnsEnvironment: String = Config.apnsEnv
    let environment: EnvironmentType = Config.environment
    var baseUrlString: String { return Config.workfinderApiBase }
    let remoteConfig: RemoteConfiguration
    
    init(registrar: RemoteNotificationsRegistrarProtocol,
         launchOptions: [UIApplication.LaunchOptionsKey : Any]?) {
        self.registrar = registrar
        self.launchOptions = launchOptions
        self.log = F4SLog()
        self.workfinderEndpoint = try! WorkfinderEndpoint(baseUrlString: baseUrlString)
        self.remoteConfig = RemoteConfiguration()
        self.remoteConfig.start()
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
    
    lazy var versionCheckingService: VersionCheckingServiceProtocol = {
        return VersionCheckingService()
    }()
    
    lazy var injection: CoreInjectionProtocol = {
        return CoreInjection(
            launchOptions: self.launchOptions,
            networkConfig: self.networkConfiguration,
            appInstallationLogic: self.appInstallationLogic,
            user: self.userRepo.loadCandidate(),
            userService: self.userService,
            userRepository: self.userRepo,
            companyDownloadFileManager: self.companyFileDownloadManager,
            log: self.log,
            appSettings: self.remoteConfig)
    }()
    
    lazy var versionCheckCoordinator: VersionCheckCoordinatorProtocol = {
        return VersionCheckCoordinator(
            parent: nil,
            navigationRouter: self.rootNavigationRouter,
            versionCheckService: self.versionCheckingService)
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
                              documentUploaderFactory: documentUploaderFactory,
                              emailVerificationModel: emailVerificationModel,
                              localStore: localStore,
                              onboardingCoordinatorFactory: onboardingCoordinatorFactory,
                              placementDocumentsServiceFactory: placementDocumentsServiceFactory,
                              roleService: roleService,
                              tabBarCoordinatorFactory: self,
                              versionCheckCoordinator: versionCheckCoordinator,
                              window: self.window)
    }
    
    lazy var companyCoordinatorFactory: CompanyCoordinatorFactoryProtocol = {
        let applyService = ApplyService()
        return CompanyCoordinatorFactory(applyService: applyService,
                                         hostsProvider: self.hostsProvider,
                                         documentServiceFactory: self.placementDocumentsServiceFactory,
                                         documentUploaderFactory: documentUploaderFactory,
                                         emailVerificationModel: self.emailVerificationModel,
                                         environment: environment,
                                         interestsRepository: interestsRepository)
    }()
    
    var log: F4SAnalyticsAndDebugging
    
    lazy var placementDocumentsServiceFactory: F4SPlacementDocumentsServiceFactoryProtocol = {
        return F4SPlacementDocumentsServiceFactory()
    }()
    
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
    
    lazy var documentUploaderFactory: F4SDocumentUploaderFactoryProtocol = {
        return F4SDocumentUploaderFactory(configuration: self.networkConfiguration)
    }()
    
    lazy var emailVerificationModel: F4SEmailVerificationModel = {
        let service = self.emailVerificationServiceFactory.makeEmailVerificationService()
        return F4SEmailVerificationModel(localStore: localStore,
                                         emailVerificationService: service)
    }()
    
    lazy var emailVerificationServiceFactory: EmailVerificationServiceFactoryProtocol = {
        return EmailVerificationServiceFactory(configuration: self.networkConfiguration)
    }()
    
    lazy var interestsRepository: F4SInterestsRepositoryProtocol = {
        return F4SInterestsRepository(localStore: self.localStore)
    }()
    
    lazy var onboardingCoordinatorFactory: OnboardingCoordinatorFactoryProtocol = {
         return OnboardingCoordinatorFactory(localStore: self.localStore)
     }()

}
