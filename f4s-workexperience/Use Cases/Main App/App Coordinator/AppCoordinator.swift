import UIKit
import WorkfinderCommon
import WorkfinderNetworking
import GoogleMaps
import GooglePlaces

extension UIApplication : RemoteNotificationsRegistrarProtocol {}

/// UIApplication conforms to this protocol
public protocol RemoteNotificationsRegistrarProtocol {
    func registerForRemoteNotifications()
}

public protocol AppCoordinatorProtocol : Coordinating {
    var window: UIWindow { get }
}

protocol AppCoordinatoryFactoryProtocol {}

struct AppCoordinatoryFactory : AppCoordinatoryFactoryProtocol {
    
    func makeAppCoordinator(
        registrar: RemoteNotificationsRegistrarProtocol,
        launchOptions: LaunchOptions? = nil,
        installationUuid: F4SUUID,
        user: F4SUserProtocol = F4SUser(),
        userService: F4SUserServiceProtocol = F4SUserService(),
        userRepository: F4SUserRepositoryProtocol = F4SUserRepository(),
        databaseDownloadManager: F4SDatabaseDownloadManagerProtocol = F4SDatabaseDownloadManager(),
        navigationRouter: NavigationRoutingProtocol = NavigationRouter(navigationController: UINavigationController(rootViewController: AppCoordinatorBackgroundViewController())),
        f4sLog: F4SAnalyticsAndDebugging
        ) -> AppCoordinatorProtocol {
        
        let injection = CoreInjection(
            launchOptions: launchOptions,
            installationUuid: installationUuid,
            user: user,
            userService: userService,
            userRepository: userRepository,
            databaseDownloadManager: databaseDownloadManager,
            f4sLog: f4sLog)
        
        return AppCoordinator(registrar: registrar,
                              navigationRouter: navigationRouter,
                              inject: injection)
    }
}

class AppCoordinator : NavigationCoordinator, AppCoordinatorProtocol {
    
    var window: UIWindow
    var injected: CoreInjectionProtocol
    var registrar: RemoteNotificationsRegistrarProtocol
    var launchOptions: [UIApplication.LaunchOptionsKey: Any]? { return injected.launchOptions }
    var user: F4SUserProtocol { return injected.user }
    var userService: F4SUserServiceProtocol { return injected.userService}
    var databaseDownloadManager: F4SDatabaseDownloadManagerProtocol { return injected.databaseDownloadManager }
    
    lazy var onboardingCoordinatorFactory: (_ parent: Coordinating?, _ router: NavigationRoutingProtocol) -> OnboardingCoordinatorProtocol = { [unowned self] _,_ in
        return OnboardingCoordinator(parent: self, navigationRouter: self.navigationRouter)
    }
    
    lazy var tabBarCoordinator: TabBarCoordinatorProtocol = {
        return tabBarCoordinatorFactory(self, navigationRouter, injected)
    }()
    
    lazy var tabBarCoordinatorFactory: (_ parent: Coordinating?, _ router: NavigationRoutingProtocol, _ inject: CoreInjectionProtocol) -> TabBarCoordinatorProtocol = {parent, router, inject in
        let tabBarCoordinator = TabBarCoordinator(parent: parent, navigationRouter: router, inject: inject)
        TabBarCoordinator.sharedInstance = tabBarCoordinator
        return tabBarCoordinator
    }
    
    public init(registrar: RemoteNotificationsRegistrarProtocol,
                navigationRouter: NavigationRoutingProtocol,
                inject: CoreInjectionProtocol) {
        
        self.registrar = registrar
        self.injected = inject
        window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = navigationRouter.rootViewController
        super.init(parent:nil, navigationRouter: navigationRouter)
        window.makeKeyAndVisible()
        configureNetwork()
    }
    
    var onboardingCoordinator: OnboardingCoordinatorProtocol?
    
    override func start() {
        GMSServices.provideAPIKey(GoogleApiKeys.googleApiKey)
        GMSPlacesClient.provideAPIKey(GoogleApiKeys.googleApiKey)
        _ = UNService.shared // ensure user notification service is wired up early
        _ = F4SEmailVerificationModel.shared
        
        let onboardingCoordinator = onboardingCoordinatorFactory(self, navigationRouter)
        self.onboardingCoordinator = onboardingCoordinator
        onboardingCoordinator.parentCoordinator = self
        onboardingCoordinator.delegate = self
        onboardingCoordinator.hideOnboardingControls = true
        onboardingCoordinator.onboardingDidFinish = onboardingDidFinish
        addChildCoordinator(onboardingCoordinator)
        onboardingCoordinator.start()
        ensureDeviceIsRegistered { [weak self] userUuid in
            self?.onUserIsRegistered(userUuid: userUuid)
        }
    }
    
    private func onboardingDidFinish(onboardingCoordinator: OnboardingCoordinatorProtocol) {
        navigationRouter.dismiss(animated: false, completion: nil)
        removeChildCoordinator(onboardingCoordinator)
        startTabBarCoordinator()
    }
    
    var shouldShowTimeline: Bool = false {
        didSet {
            UserDefaults.standard.set(false, forKey: UserDefaultsKeys.shouldLoadTimeline)
        }
    }
    
    private func onUserIsRegistered(userUuid: F4SUUID) {
        injected.user.updateUuid(uuid: userUuid)
        injected.userRepository.save(user: injected.user)
        printDebugUserInfo()
        injected.log.identity(userId: userUuid)
        _ = F4SNetworkSessionManager.shared
        registrar.registerForRemoteNotifications()
        F4SUserStatusService.shared.beginStatusUpdate()
        databaseDownloadManager.start()
        showOnboardingUIIfNecessary()
    }
    
    func showOnboardingUIIfNecessary() {
        if user.isOnboarded {
            onboardingDidFinish(onboardingCoordinator: onboardingCoordinator!)
        } else {
            onboardingCoordinator?.hideOnboardingControls = false
        }
    }
    
    private func startTabBarCoordinator() {
        addChildCoordinator(tabBarCoordinator)
        tabBarCoordinator.start()
    }
    
    
    private func ensureDeviceIsRegistered(completion: @escaping (F4SUUID)->()) {
        let installationUuid = injected.installationUuid
        let userUuid = injected.user.uuid
        userService.registerDeviceWithServer(installationUuid: installationUuid) { [weak self] (result) in
            guard let strongSelf = self else { return }
            switch result {
            case .error(_):
                globalLog.info("Couldn't register user, offering retry")
                strongSelf.presentNoNetworkMustRetry(retryOperation: {
                    strongSelf.ensureDeviceIsRegistered(completion: completion)
                })
            case .success(let result):
                guard let anonymousUserUuid = result.uuid else {
                    globalLog.severe("registering user failed to obtain uuid")
                    fatalError("registering user failed to obtain uuid")
                }
                completion(userUuid ?? anonymousUserUuid)
            }
        }
    }
}

extension AppCoordinator {
    func presentForceUpdate() {
        let rootVC = window.rootViewController?.topMostViewController
        let forceUpdateVC = F4SForceAppUpdateViewController()
        rootVC?.present(forceUpdateVC, animated: true, completion: nil)
    }
    
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
    func printDebugUserInfo() {
        let info = """
        
        
        ****************************************************************
        Environment name = \(Config.environmentName)
        Installation UUID = \(injected.installationUuid)
        User UUID = \(F4SUser().uuid ?? "nil user")
        Base api url = \(NetworkConfig.workfinderApi)
        V1 api url = \(NetworkConfig.workfinderApiV1)
        v2 api url = \(NetworkConfig.workfinderApiV2)
        ****************************************************************
        
        """
        injected.log.debug(info, functionName: #function, fileName: #file, lineNumber: #line)
    }
    
    func configureNetwork(
        wexApiKey: String = ApiConstants.apiKey,
        baseUrlString: String = Config.workfinderApiBase) {
        NetworkConfig.configure(wexApiKey: wexApiKey, workfinderBaseApi: baseUrlString, log: injected.log)
    }
}

extension AppCoordinator : OnboardingCoordinatorDelegate {
    func shouldEnableLocation(_ enable: Bool) {
        tabBarCoordinator.shouldAskOperatingSystemToAllowLocation = enable
    }
}
