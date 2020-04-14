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
    var versionCheckCoordinator: VersionCheckCoordinatorProtocol?
    
    let companyCoordinatorFactory: CompanyCoordinatorFactoryProtocol
    let hostsProvider: HostsProviderProtocol
    let documentUploaderFactory: F4SDocumentUploaderFactoryProtocol
    let emailVerificationModel: F4SEmailVerificationModelProtocol
    let onboardingCoordinatorFactory: OnboardingCoordinatorFactoryProtocol
    let placementDocumentsServiceFactory: F4SPlacementDocumentsServiceFactoryProtocol
    let roleService: F4SRoleServiceProtocol
    let tabBarCoordinatorFactory: TabbarCoordinatorFactoryProtocol
    var user: Candidate { return injected.userRepository.loadCandidate() }
    var userService: F4SUserServiceProtocol { return injected.userService}
    var databaseDownloadManager: F4SCompanyDownloadManagerProtocol { return injected.companyDownloadFileManager }
    var userNotificationService: UNService!
    var log: F4SAnalyticsAndDebugging { return injected.log }
    let localStore: LocalStorageProtocol
    
    public init(registrar: RemoteNotificationsRegistrarProtocol,
                navigationRouter: NavigationRoutingProtocol,
                inject: CoreInjectionProtocol,
                companyCoordinatorFactory: CompanyCoordinatorFactoryProtocol,
                hostsProvider: HostsProviderProtocol,
                documentUploaderFactory: F4SDocumentUploaderFactoryProtocol,
                emailVerificationModel: F4SEmailVerificationModelProtocol,
                localStore: LocalStorageProtocol,
                onboardingCoordinatorFactory: OnboardingCoordinatorFactoryProtocol,
                placementDocumentsServiceFactory: F4SPlacementDocumentsServiceFactoryProtocol,
                roleService: F4SRoleServiceProtocol,
                tabBarCoordinatorFactory: TabbarCoordinatorFactoryProtocol,
                versionCheckCoordinator: VersionCheckCoordinatorProtocol,
                window: UIWindow) {
        
        self.window = window
        self.registrar = registrar
        self.injected = inject
        
        self.companyCoordinatorFactory = companyCoordinatorFactory
        self.hostsProvider = hostsProvider
        self.documentUploaderFactory = documentUploaderFactory
        
        self.emailVerificationModel = emailVerificationModel
        self.localStore = localStore
        self.placementDocumentsServiceFactory = placementDocumentsServiceFactory
        
        self.onboardingCoordinatorFactory = onboardingCoordinatorFactory
        self.roleService = roleService
        self.tabBarCoordinatorFactory = tabBarCoordinatorFactory
        self.versionCheckCoordinator = versionCheckCoordinator

        super.init(parent:nil, navigationRouter: navigationRouter)
        self.injected.appCoordinator = self
        versionCheckCoordinator.parentCoordinator = self
        userNotificationService = UNService(appCoordinator: self)
    }
    
    override func start() {
        GMSServices.provideAPIKey(GoogleApiKeys.googleApiKey)
        GMSPlacesClient.provideAPIKey(GoogleApiKeys.googleApiKey)
        if launchOptions?[.remoteNotification] == nil {
            performVersionCheck(resultHandler: self.onVersionCheckResult)
        } else {
            startTabBarCoordinator()
        }
    }
    
    func performVersionCheck(resultHandler: @escaping (F4SNetworkResult<F4SVersionValidity>)->Void) {
        guard let versionCheckCoordinator = versionCheckCoordinator else { return }
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
                self?.versionCheckCoordinator?.start()
            })
        case .success(let isValid):
            guard isValid else { return }
            startOnboarding()
            versionCheckCoordinator = nil
        }
    }
    
    func startOnboarding() {
        let onboardingCoordinator = onboardingCoordinatorFactory.makeOnboardingCoordinator(parent: self, navigationRouter: navigationRouter)
        self.onboardingCoordinator = onboardingCoordinator
        onboardingCoordinator.parentCoordinator = self
        onboardingCoordinator.delegate = self
        onboardingCoordinator.hideOnboardingControls = true
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
        showOnboardingUIIfNecessary()
    }
    
    func showOnboardingUIIfNecessary() {
        let onboardingRequired = localStore.value(key: LocalStore.Key.isFirstLaunch) as! Bool? ?? true
        
        if onboardingRequired {
            onboardingCoordinator?.hideOnboardingControls = false
        } else {
            onboardingDidFinish(onboardingCoordinator: onboardingCoordinator!)
        }
    }
    
    private func startTabBarCoordinator() {
        tabBarCoordinator = tabBarCoordinatorFactory.makeTabBarCoordinator(
            parent: self,
            router: navigationRouter,
            inject: injected)
        tabBarCoordinator.shouldAskOperatingSystemToAllowLocation = shouldAskOperatingSystemToAllowLocation
        addChildCoordinator(tabBarCoordinator)
        tabBarCoordinator.start()
        performVersionCheck { (result) in }
    }
    
    func showSearch() { tabBarCoordinator.showSearch() }
    
    func showMessages() { tabBarCoordinator.showMessages() }

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
