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
    func performVersionCheck(resultHandler: @escaping ((F4SNetworkResult<F4SVersionValidity>)->Void))
}

class AppCoordinator : NavigationCoordinator, AppCoordinatorProtocol {

    var window: UIWindow
    var injected: CoreInjectionProtocol
    var registrar: RemoteNotificationsRegistrarProtocol
    var launchOptions: [UIApplication.LaunchOptionsKey: Any]? { return injected.launchOptions }
    var user: F4SUserProtocol { return injected.user }
    var userService: F4SUserServiceProtocol { return injected.userService}
    var databaseDownloadManager: F4SDatabaseDownloadManagerProtocol { return injected.databaseDownloadManager }
    var versionCheckCoordinator: NavigationCoordinator & VersionChecking
    
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
    
    public init(versionCheckCoordinator: NavigationCoordinator & VersionChecking,
                registrar: RemoteNotificationsRegistrarProtocol,
                navigationRouter: NavigationRoutingProtocol,
                inject: CoreInjectionProtocol) {
        self.versionCheckCoordinator = versionCheckCoordinator
        self.registrar = registrar
        self.injected = inject
        window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = navigationRouter.rootViewController
        super.init(parent:nil, navigationRouter: navigationRouter)
        versionCheckCoordinator.parentCoordinator = self
        window.makeKeyAndVisible()
    }
    
    var onboardingCoordinator: OnboardingCoordinatorProtocol?
    
    override func start() {
        GMSServices.provideAPIKey(GoogleApiKeys.googleApiKey)
        GMSPlacesClient.provideAPIKey(GoogleApiKeys.googleApiKey)
        _ = UNService.shared // ensure user notification service is wired up early
        _ = F4SEmailVerificationModel.shared
        if launchOptions?[.remoteNotification] == nil {
            performVersionCheck(resultHandler: onVersionCheckResult)
        } else {
            startTabBarCoordinator()
        }
    }
    
    func performVersionCheck(resultHandler: @escaping (F4SNetworkResult<F4SVersionValidity>)->Void) {
        if !childCoordinators.contains(where: { (key, coordinating) -> Bool in
            coordinating.uuid == versionCheckCoordinator.uuid
        }) {
            addChildCoordinator(versionCheckCoordinator)
        }
        versionCheckCoordinator.versionCheckCompletion = resultHandler
        versionCheckCoordinator.start()
    }
    
    func onVersionCheckResult(_ result:F4SNetworkResult<F4SVersionValidity>) {
        switch result {
        case .error(_):
            self.presentNoNetworkMustRetry(retryOperation: { [weak self] in
                self?.versionCheckCoordinator.start()
            })
        case .success(let isValid):
            guard isValid else { return }
            startOnboarding()
        }
    }
    
    func startOnboarding() {
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
        logStartupInformation()
        injected.log.identity(userId: userUuid)
        _ = F4SNetworkSessionManager.shared
        registrar.registerForRemoteNotifications()
        injected.userStatusService.beginStatusUpdate()
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
        performVersionCheck { (result) in }
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
    func logStartupInformation() {
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
}

extension AppCoordinator : OnboardingCoordinatorDelegate {
    func shouldEnableLocation(_ enable: Bool) {
        tabBarCoordinator.shouldAskOperatingSystemToAllowLocation = enable
    }
}
