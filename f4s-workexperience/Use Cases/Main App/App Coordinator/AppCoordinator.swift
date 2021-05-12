import UIKit
import WorkfinderCommon
import WorkfinderNetworking
import WorkfinderServices
import WorkfinderCoordinators
import WorkfinderUserDetailsUseCase
import WorkfinderCompanyDetailsUseCase
import WorkfinderOnboardingUseCase
import WorkfinderRegisterCandidate

extension UIApplication {}

class AppCoordinator : NavigationCoordinator, AppCoordinatorProtocol {
    var window: UIWindow
    var injected: CoreInjectionProtocol
    var launchOptions: [UIApplication.LaunchOptionsKey: Any]? { return injected.launchOptions }
    var tabBarCoordinator: TabBarCoordinatorProtocol?
    var onboardingCoordinator: OnboardingCoordinatorProtocol?
    var deepLinkRouter: DeepLinkRouter?
    let companyCoordinatorFactory: CompanyCoordinatorFactoryProtocol
    let hostsProvider: HostsProviderProtocol
    let onboardingCoordinatorFactory: OnboardingCoordinatorFactoryProtocol
    var deviceRegistrar: DeviceRegisteringProtocol?
    
    let tabBarCoordinatorFactory: TabbarCoordinatorFactoryProtocol
    var user: Candidate { return injected.userRepository.loadCandidate() }
    var userNotificationService: UNService!
    var log: F4SAnalyticsAndDebugging { return injected.log }
    let localStore: LocalStorageProtocol
    var suppressOnboarding: Bool
    
    public init(navigationRouter: NavigationRoutingProtocol,
                inject: CoreInjectionProtocol,
                deviceRegistrar: DeviceRegisteringProtocol?,
                companyCoordinatorFactory: CompanyCoordinatorFactoryProtocol,
                hostsProvider: HostsProviderProtocol,
                localStore: LocalStorageProtocol,
                onboardingCoordinatorFactory: OnboardingCoordinatorFactoryProtocol,
                tabBarCoordinatorFactory: TabbarCoordinatorFactoryProtocol,
                window: UIWindow,
                suppressOnboarding: Bool = false
    ) {
        
        self.window = window
        self.injected = inject
        self.companyCoordinatorFactory = companyCoordinatorFactory
        self.hostsProvider = hostsProvider
        self.localStore = localStore
        self.deviceRegistrar = deviceRegistrar
        self.onboardingCoordinatorFactory = onboardingCoordinatorFactory
        self.tabBarCoordinatorFactory = tabBarCoordinatorFactory
        self.suppressOnboarding = suppressOnboarding
        super.init(parent:nil, navigationRouter: navigationRouter)
        self.deepLinkRouter = DeepLinkRouter(log: inject.log, coordinator: self)
        self.injected.appCoordinator = self
        userNotificationService = UNService(appCoordinator: self, userRepository: injected.userRepository)
    }
    
    override func start() {
        trackAppStart()
        printUserInfo()
        injected.versionChecker.performChecksWithHardStop { [weak self] (optionalError) in
            guard let self = self else { return }
            switch self.suppressOnboarding {
            case true:
                self.localStore.setValue(false, for: .isOnboardingRequired)
                self.startTabBarCoordinator()
            case false:
                self.startOnboarding()
            }
            if self.injected.userRepository.isCandidateLoggedIn {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func trackAppStart() {
        let localStore = LocalStore()
        let isFirstLaunch = localStore.value(key: .isFirstLaunch) as? Bool ?? true
        if isFirstLaunch { log.track(.first_use) }
        localStore.setValue(false, for: .isFirstLaunch)
        log.track(.app_open)
    }
    
    func printUserInfo() {
        let userRepo = injected.userRepository
        let user = userRepo.loadUser()
        let candidate = userRepo.loadCandidate()
        print("\n\n-----------------------------------------------------------")
        switch userRepo.isCandidateLoggedIn {
        case true:
            print("Candidate \(candidate.fullName)")
            print("Email \(user.email ?? "unknown")")
            print("User uuid \(user.uuid ?? "unknown")")
            print("Candidate uuid \(candidate.uuid ?? "unknown")")
        case false:
            print("Candidate not signed in")
        }
        print("-----------------------------------------------------------\n\n")
    }
    
    func startOnboarding() {
        let onboardingCoordinator = onboardingCoordinatorFactory.makeOnboardingCoordinator(
            parent: self,
            navigationRouter: navigationRouter,
            inject: injected,
            log: log)
        self.onboardingCoordinator = onboardingCoordinator
        onboardingCoordinator.parentCoordinator = self
        onboardingCoordinator.onboardingDidFinish = onboardingDidFinish
        addChildCoordinator(onboardingCoordinator)
        onboardingCoordinator.start()
        onUserIsRegistered(userUuid: "")
    }
    
    private func onboardingDidFinish(onboardingCoordinator: OnboardingCoordinatorProtocol) {
        navigationRouter.dismiss(animated: false, completion: nil)
        removeChildCoordinator(onboardingCoordinator)
        startTabBarCoordinator()
    }
    
    private func onUserIsRegistered(userUuid: F4SUUID) {
        injected.user.uuid = userUuid
        logStartupInformation(userId: userUuid)
    }
    
    private func startTabBarCoordinator() {
        let tabBarCoordinator = tabBarCoordinatorFactory.makeTabBarCoordinator(
            parent: self,
            router: navigationRouter,
            inject: injected)
        addChildCoordinator(tabBarCoordinator)
        self.tabBarCoordinator = tabBarCoordinator
        tabBarCoordinator.start()
    }
    
    func requestPushNotifications(from viewController: UIViewController, completion: @escaping () -> Void) {
        guard injected.userRepository.isCandidateLoggedIn else {
            completion()
            return
        }
        userNotificationService.authorize(from: viewController, completion: completion)
    }
    
    lazy var recommendationService: RecommendationsServiceProtocol = {
        let service = RecommendationsService(networkConfig: injected.networkConfig)
        return service
    }()
    
    func switchToTab(_ tab: TabIndex) { tabBarCoordinator?.switchToTab(tab) }
    
    func routeApplication(placementUuid: F4SUUID?, appSource: AppSource) {
        tabBarCoordinator?.routeApplication(placementUuid: placementUuid, appSource: appSource)
    }
    
    func routeProject(projectUuid: F4SUUID?, appSource: AppSource) {
        guard let projectUuid = projectUuid else { return }
        if let tabBarCoordinator = self.tabBarCoordinator {
            tabBarCoordinator.routeProject(projectUuid: projectUuid, appSource: appSource)
            return
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.1) { [weak self] in
            self?.routeProject(projectUuid: projectUuid, appSource: appSource)
        }
    }
    
    func routeReview(reviewUuid: F4SUUID, appSource: AppSource, queryItems: [String: String]) {
        if let tabBarCoordinator = self.tabBarCoordinator {
            tabBarCoordinator.routeReview(reviewUuid: reviewUuid, appSource: appSource, queryItems: queryItems)
            return
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.1) { [weak self] in
            self?.routeReview(reviewUuid: reviewUuid, appSource: appSource, queryItems: queryItems)
        }
    }
    
    func routeLiveProjects(appSource: AppSource) {
        if let tabBarCoordinator = self.tabBarCoordinator {
            tabBarCoordinator.routeLiveProjects(appSource: appSource)
            return
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.1) { [weak self] in
            self?.routeLiveProjects(appSource: appSource)
        }
    }
    
    func routeRecommendation(recommendationUuid: F4SUUID?, appSource: AppSource) {
        guard let tabBarCoordinator = tabBarCoordinator else {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.1) { [weak self] in
                self?.routeRecommendation(recommendationUuid: recommendationUuid, appSource: appSource)
            }
            return
        }
        tabBarCoordinator.switchToTab(.recommendations)
        guard let uuid = recommendationUuid else { return }
        recommendationService.fetchRecommendation(uuid: uuid) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let recommendation):
                if let projectUuid = recommendation.project?.uuid {
                    self.routeProject(projectUuid: projectUuid, appSource: appSource)
                } else {
                    tabBarCoordinator.routeRecommendationForAssociation(recommendationUuid: uuid, appSource: appSource)
                }
            case .failure(let error):
                guard let workfinderError = error as? WorkfinderError else { return }
                switch workfinderError.code {
                case 401:
                    self.signIn(screenOrder: .loginThenRegister) { loggedIn in
                        switch loggedIn {
                        case true:
                            self.routeRecommendation(recommendationUuid: uuid, appSource: appSource)
                        case false:
                            return
                        }
                    }
                default:
                    guard workfinderError.retry else {
                        return
                    }
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.5) {
                        self.routeRecommendation(recommendationUuid: uuid, appSource: appSource)
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
    
    func signIn(screenOrder: SignInScreenOrder, completion: @escaping (Bool) -> Void) {
        let loginCoordinator = LoginHandler(
            parentCoordinator: self,
            navigationRouter: self.navigationRouter,
            mainWindow: UIApplication.shared.windows.first,
            coreInjection: self.injected
        )
        addChildCoordinator(loginCoordinator)
        loginHandler.startLoginWorkflow(screenOrder: screenOrder) { [weak self] (loggedIn) in
            guard let self = self else { return }
            self.removeChildCoordinator(loginCoordinator)
            completion(loggedIn)
        }
    }
    
    func updateBadges() { tabBarCoordinator?.updateBadges() }
    
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
        let user = UserRepository().loadUser()
        let info = """

        
        ****************************************************************
        Environment name = \(Config.environmentName)
        Base api url = \(Config.workfinderApiBase)
        Candidate email = \(user.email ?? "not set")
        Candidate password = \(user.password ?? "not set")
        ****************************************************************
        
        """
        injected.log.debug(info, functionName: #function, fileName: #file, lineNumber: #line)
    }
}

extension AppCoordinator {
    
    func handlePushNotification(_ pushNotification: PushNotification?) {
        guard
            let pushNotification = pushNotification,
            let deepLinkInfo = DeeplinkRoutingInfo(pushNotification: pushNotification),
            let dispatcher = deepLinkRouter
        else { return }
        dispatcher.route(routingInfo: deepLinkInfo)
    }
    
    func handleDeepLinkUrl(url: URL) {
        guard
            let routingInfo = DeeplinkRoutingInfo(deeplinkUrl: url),
            let router = deepLinkRouter
        else {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            return
        }
        router.route(routingInfo: routingInfo)
    }

}


