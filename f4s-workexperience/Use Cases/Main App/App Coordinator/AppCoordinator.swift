import UIKit
import WorkfinderCommon
import WorkfinderNetworking
import WorkfinderServices
import WorkfinderCoordinators
import WorkfinderUserDetailsUseCase
import WorkfinderCompanyDetailsUseCase
import WorkfinderOnboardingUseCase
import WorkfinderRegisterCandidate
import GoogleMaps
import GooglePlaces

extension UIApplication {}

class AppCoordinator : NavigationCoordinator, AppCoordinatorProtocol {
    
    var window: UIWindow
    var injected: CoreInjectionProtocol
    var launchOptions: [UIApplication.LaunchOptionsKey: Any]? { return injected.launchOptions }
    var shouldAskOperatingSystemToAllowLocation: Bool = false
    var tabBarCoordinator: TabBarCoordinatorProtocol?
    var onboardingCoordinator: OnboardingCoordinatorProtocol?
    let deepLinkDispatcher: DeepLinkDispatcher
    let companyCoordinatorFactory: CompanyCoordinatorFactoryProtocol
    let hostsProvider: HostsProviderProtocol
    let onboardingCoordinatorFactory: OnboardingCoordinatorFactoryProtocol
    var deviceRegistrar: DeviceRegisteringProtocol?
    
    let tabBarCoordinatorFactory: TabbarCoordinatorFactoryProtocol
    var user: Candidate { return injected.userRepository.loadCandidate() }
    var databaseDownloadManager: F4SCompanyDownloadManagerProtocol { return injected.companyDownloadFileManager }
    var userNotificationService: UNService!
    var log: F4SAnalyticsAndDebugging { return injected.log }
    let localStore: LocalStorageProtocol
    
    public init(navigationRouter: NavigationRoutingProtocol,
                inject: CoreInjectionProtocol,
                deviceRegistrar: DeviceRegisteringProtocol?,
                companyCoordinatorFactory: CompanyCoordinatorFactoryProtocol,
                hostsProvider: HostsProviderProtocol,
                localStore: LocalStorageProtocol,
                onboardingCoordinatorFactory: OnboardingCoordinatorFactoryProtocol,
                tabBarCoordinatorFactory: TabbarCoordinatorFactoryProtocol,
                window: UIWindow) {
        
        self.window = window
        self.injected = inject
        self.deepLinkDispatcher = DeepLinkDispatcher(log: inject.log)
        self.companyCoordinatorFactory = companyCoordinatorFactory
        self.hostsProvider = hostsProvider
        self.localStore = localStore
        self.deviceRegistrar = deviceRegistrar
        self.onboardingCoordinatorFactory = onboardingCoordinatorFactory
        self.tabBarCoordinatorFactory = tabBarCoordinatorFactory
        
        super.init(parent:nil, navigationRouter: navigationRouter)
        self.injected.appCoordinator = self
        userNotificationService = UNService(appCoordinator: self, userRepository: injected.userRepository)
    }
    
    override func start() {
        injected.versionChecker.performChecksWithHardStop { [weak self] (optionalError) in
            guard let self = self else { return }
            GMSServices.provideAPIKey(GoogleApiKeys.googleApiKey)
            GMSPlacesClient.provideAPIKey(GoogleApiKeys.googleApiKey)
            self.startOnboarding()
            if self.launchOptions?[.remoteNotification] != nil {
                self.startTabBarCoordinator()
            }
            if let _ = self.injected.userRepository.loadUser().uuid {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func startOnboarding() {
        let onboardingCoordinator = onboardingCoordinatorFactory.makeOnboardingCoordinator(
            parent: self,
            navigationRouter: navigationRouter,
            inject: injected,
            log: log)
        self.onboardingCoordinator = onboardingCoordinator
        onboardingCoordinator.parentCoordinator = self
        onboardingCoordinator.delegate = self
        onboardingCoordinator.isFirstLaunch = localStore.value(key: LocalStore.Key.isFirstLaunch) as? Bool ?? true
        onboardingCoordinator.onboardingDidFinish = onboardingDidFinish
        addChildCoordinator(onboardingCoordinator)
        onboardingCoordinator.start()
        onUserIsRegistered(userUuid: "")
    }
    
    private func onboardingDidFinish(onboardingCoordinator: OnboardingCoordinatorProtocol) {
        localStore.setValue(false, for: LocalStore.Key.isFirstLaunch)
        navigationRouter.dismiss(animated: false, completion: nil)
        removeChildCoordinator(onboardingCoordinator)
        startTabBarCoordinator()
    }
    
    private func onUserIsRegistered(userUuid: F4SUUID) {
        injected.user.uuid = userUuid
        logStartupInformation(userId: userUuid)
        databaseDownloadManager.start()
    }
    
    private func startTabBarCoordinator() {
        let tabBarCoordinator = tabBarCoordinatorFactory.makeTabBarCoordinator(
            parent: self,
            router: navigationRouter,
            inject: injected)
        tabBarCoordinator.shouldAskOperatingSystemToAllowLocation = shouldAskOperatingSystemToAllowLocation
        addChildCoordinator(tabBarCoordinator)
        self.tabBarCoordinator = tabBarCoordinator
        tabBarCoordinator.start()
    }
    
    func showApplications() { tabBarCoordinator?.showApplications() }
    
    func showSearch() { tabBarCoordinator?.showSearch() }
    
    func requestPushNotifications(from viewController: UIViewController) {
        userNotificationService.authorize(from: viewController)
    }
    
    lazy var recommendationService: RecommendationsServiceProtocol = {
        let service = RecommendationsService(networkConfig: injected.networkConfig)
        return service
    }()
    
    func handleDeeplink(info: DeeplinkDispatchInfo) {
        let applicationSource = ApplicationSource(source: info.source)
        switch info.objectType {
        case .application:
            break
        case .recommendation:
            switch info.action {
            case .list:
                showRecommendation(uuid: nil, applicationSource: applicationSource)
            case .view(let uuid):
                showRecommendation(uuid: uuid, applicationSource: applicationSource)
            }
        case .project:
            break
        }
    }
    
    func showProject(uuid: F4SUUID?, applicationSource: ApplicationSource) {
        guard let uuid = uuid else { return }
        if let tabBarCoordinator = self.tabBarCoordinator {
            tabBarCoordinator.dispatchProjectViewRequest(uuid, applicationSource: applicationSource)
            return
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.1) { [weak self] in
            self?.showProject(uuid: uuid, applicationSource: applicationSource)
        }
    }
    
    func showRecommendation(uuid: F4SUUID?, applicationSource: ApplicationSource) {
        guard let tabBarCoordinator = tabBarCoordinator else {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.1) { [weak self] in
                self?.showRecommendation(uuid: uuid, applicationSource: applicationSource)
            }
            return
        }
        guard let uuid = uuid else {
            tabBarCoordinator.navigateToRecommendations()
            return
        }
        recommendationService.fetchRecommendation(uuid: uuid) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let recommendation):
                if let projectUuid = recommendation.project?.uuid {
                    self.showProject(uuid: projectUuid, applicationSource: applicationSource)
                } else {
                    tabBarCoordinator.dispatchRecommendationToSearchTab(uuid: uuid)
                }
            case .failure(let error):
                guard let workfinderError = error as? WorkfinderError else { return }
                switch workfinderError.code {
                case 401:
                    self.signIn() { loggedIn in
                        switch loggedIn {
                        case true:
                            self.showRecommendation(uuid: uuid, applicationSource: applicationSource)
                        case false:
                            return
                        }
                    }
                default:
                    guard workfinderError.retry else { return }
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.5) {
                        self.showRecommendation(uuid: uuid, applicationSource: applicationSource)
                    }
                }
            }
        }
    }
    
    lazy var loginHandler: LoginHandler = {
        return LoginHandler(
            parentCoordinator: self,
            navigationRouter: self.navigationRouter,
            mainWindow: UIApplication.shared.windows.first,
            coreInjection: self.injected
        )
    }()
    
    func signIn(completion: @escaping (Bool) -> Void) {
        let loginCoordinator = LoginHandler(
            parentCoordinator: self,
            navigationRouter: self.navigationRouter,
            mainWindow: UIApplication.shared.windows.first,
            coreInjection: self.injected
        )
        addChildCoordinator(loginCoordinator)
        loginHandler.startLoginWorkflow { [weak self] (loggedIn) in
            guard let self = self else { return }
            self.removeChildCoordinator(loginCoordinator)
            completion(loggedIn)
        }
    }
    
    func updateBadges() { tabBarCoordinator?.updateBadges() }
    
    func handleRemoteNotification(userInfo: [AnyHashable : Any]) {
        userNotificationService.handleRemoteNotification(userInfo: userInfo)
    }
}

extension AppCoordinator : DeviceRegisteringProtocol {
    func registerDevice(token: Data) {
        deviceRegistrar = DeviceRegistrar(
            userRepository: injected.userRepository,
            environmentType: Config.environment,
            log: log
        )
        deviceRegistrar?.registerDevice(token: token)
    }
}

extension AppCoordinator {
    func logStartupInformation(userId: F4SUUID) {
        let info = """

        
        ****************************************************************
        Environment name = \(Config.environmentName)
        Base api url = \(Config.workfinderApiBase)
        Candidate email = \(UserRepository().loadUser().email ?? "not set")
        Candidate password = \(UserRepository().loadUser().password ?? "not set")
        ****************************************************************
        
        """
        injected.log.debug(info, functionName: #function, fileName: #file, lineNumber: #line)
    }
}

extension AppCoordinator : OnboardingCoordinatorDelegate {
    func shouldEnableLocation(_ enable: Bool) {
        shouldAskOperatingSystemToAllowLocation = enable
    }
}

extension AppCoordinator {
    func handleDeepLinkUrl(url: URL) -> Bool {
        deepLinkDispatcher.dispatchDeepLink(url, with: self)
        return true
    }
}


