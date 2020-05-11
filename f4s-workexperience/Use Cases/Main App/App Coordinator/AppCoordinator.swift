import UIKit
import WorkfinderCommon
import WorkfinderNetworking
import WorkfinderServices
import WorkfinderCoordinators
import WorkfinderUserDetailsUseCase
import WorkfinderOnboardingUseCase
import GoogleMaps
import GooglePlaces

extension UIApplication : RemoteNotificationsRegistrarProtocol {}

class AppCoordinator : NavigationCoordinator, AppCoordinatorProtocol {

    var window: UIWindow
    var injected: CoreInjectionProtocol
    var registrar: RemoteNotificationsRegistrarProtocol
    var launchOptions: [UIApplication.LaunchOptionsKey: Any]? { return injected.launchOptions }
    var shouldAskOperatingSystemToAllowLocation: Bool = false
    var tabBarCoordinator: TabBarCoordinatorProtocol!
    var onboardingCoordinator: OnboardingCoordinatorProtocol?
    
    let companyCoordinatorFactory: CompanyCoordinatorFactoryProtocol
    let hostsProvider: HostsProviderProtocol
    let onboardingCoordinatorFactory: OnboardingCoordinatorFactoryProtocol

    let tabBarCoordinatorFactory: TabbarCoordinatorFactoryProtocol
    var user: Candidate { return injected.userRepository.loadCandidate() }
    var databaseDownloadManager: F4SCompanyDownloadManagerProtocol { return injected.companyDownloadFileManager }
    var userNotificationService: UNService!
    var log: F4SAnalyticsAndDebugging { return injected.log }
    let localStore: LocalStorageProtocol
    
    public init(registrar: RemoteNotificationsRegistrarProtocol,
                navigationRouter: NavigationRoutingProtocol,
                inject: CoreInjectionProtocol,
                companyCoordinatorFactory: CompanyCoordinatorFactoryProtocol,
                hostsProvider: HostsProviderProtocol,
                localStore: LocalStorageProtocol,
                onboardingCoordinatorFactory: OnboardingCoordinatorFactoryProtocol,
                tabBarCoordinatorFactory: TabbarCoordinatorFactoryProtocol,
                window: UIWindow) {
        
        self.window = window
        self.registrar = registrar
        self.injected = inject
        
        self.companyCoordinatorFactory = companyCoordinatorFactory
        self.hostsProvider = hostsProvider
        self.localStore = localStore
        
        self.onboardingCoordinatorFactory = onboardingCoordinatorFactory
        self.tabBarCoordinatorFactory = tabBarCoordinatorFactory

        super.init(parent:nil, navigationRouter: navigationRouter)
        self.injected.appCoordinator = self
        userNotificationService = UNService(appCoordinator: self)
    }
    
    override func start() {
        GMSServices.provideAPIKey(GoogleApiKeys.googleApiKey)
        GMSPlacesClient.provideAPIKey(GoogleApiKeys.googleApiKey)
        startOnboarding()
        if launchOptions?[.remoteNotification] != nil {
            startTabBarCoordinator()
        }
    }
        
    func startOnboarding() {
        let onboardingCoordinator = onboardingCoordinatorFactory.makeOnboardingCoordinator(parent: self, navigationRouter: navigationRouter)
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
    
    var shouldShowTimeline: Bool = false {
        didSet {
            localStore.setValue(false, for: LocalStore.Key.shouldLoadTimeline)
        }
    }
    
    private func onUserIsRegistered(userUuid: F4SUUID) {
        injected.user.uuid = userUuid
        //injected.userRepository.save(user: injected.user)
        logStartupInformation(userId: userUuid)
        injected.log.identity(userId: userUuid)
        registrar.registerForRemoteNotifications()
        databaseDownloadManager.start()
    }
    
    private func startTabBarCoordinator() {
        tabBarCoordinator = tabBarCoordinatorFactory.makeTabBarCoordinator(
            parent: self,
            router: navigationRouter,
            inject: injected)
        tabBarCoordinator.shouldAskOperatingSystemToAllowLocation = shouldAskOperatingSystemToAllowLocation
        addChildCoordinator(tabBarCoordinator)
        tabBarCoordinator.start()
    }
    
    func showSearch() { tabBarCoordinator.showSearch() }

    func showRecommendations() { tabBarCoordinator?.showRecommendations() }
    
    func updateBadges() { tabBarCoordinator.updateBadges() }
    
    func handleRemoteNotification(userInfo: [AnyHashable : Any]) {
        userNotificationService.handleRemoteNotification(userInfo: userInfo)
    }
}

extension AppCoordinator {
    
    func presentNoNetworkMustRetry(retryOperation: @escaping () -> ()) {
        let rootVC = window.rootViewController?.topMostViewController
        let alert = UIAlertController(
            title: NSLocalizedString("No Network", comment: ""),
            message: NSLocalizedString("Please ensure you have a good network connection while we set things up for you", comment: ""),
            preferredStyle: .alert)
        let retry = UIAlertAction(
            title: NSLocalizedString("Retry", comment: ""),
            style: .default) { (_) in
                alert.dismiss(animated: false, completion: nil)
                retryOperation()
        }
        alert.addAction(retry)
        rootVC?.present(alert, animated: true, completion: nil)
    }
    
    func presentFatalError(error: Error) {
        let rootVC = window.rootViewController
        let alert = UIAlertController(
            title: NSLocalizedString("Workfinder cannot continue", comment: ""),
            message: NSLocalizedString("We are very sorry, this should not have happened. Workfinder has encountered an error it cannot recover from", comment: ""),
            preferredStyle: .alert)
        let retry = UIAlertAction(
            title: NSLocalizedString("Close Workfinder", comment: ""),
            style: .default) { (_) in
                fatalError()
        }
        alert.addAction(retry)
        rootVC?.present(alert, animated: true, completion: nil)
    }
}

extension AppCoordinator {
    func logStartupInformation(userId: F4SUUID) {
        let info = """

        
        ****************************************************************
        Environment name = \(Config.environmentName)
        Base api url = \(Config.workfinderApiBase)
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
