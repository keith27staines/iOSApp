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
    let companyDocumentsService: F4SCompanyDocumentServiceProtocol
    let companyRepository: F4SCompanyRepositoryProtocol
    let companyService: F4SCompanyServiceProtocol
    let documentUploaderFactory: F4SDocumentUploaderFactoryProtocol
    let emailVerificationModel: F4SEmailVerificationModelProtocol
    let favouritesRepository: F4SFavouritesRepositoryProtocol
    let onboardingCoordinatorFactory: OnboardingCoordinatorFactoryProtocol
    let offerProcessingService: F4SOfferProcessingServiceProtocol
    let partnersModel: F4SPartnersModelProtocol
    let placementsRepository: F4SPlacementRepositoryProtocol
    let placementService: F4SPlacementServiceProtocol
    let placementDocumentsServiceFactory: F4SPlacementDocumentsServiceFactoryProtocol
    let messageServiceFactory: F4SMessageServiceFactoryProtocol
    let messageActionServiceFactory: F4SMessageActionServiceFactoryProtocol
    let messageCannedResponsesServiceFactory: F4SCannedMessageResponsesServiceFactoryProtocol
    let recommendationsService: F4SRecommendationServiceProtocol
    let roleService: F4SRoleServiceProtocol
    let tabBarCoordinatorFactory: TabbarCoordinatorFactoryProtocol
    var user: F4SUser { return injected.userRepository.load() }
    var userService: F4SUserServiceProtocol { return injected.userService}
    var databaseDownloadManager: F4SDatabaseDownloadManagerProtocol { return injected.databaseDownloadManager }
    var userNotificationService: UNService!
    var log: F4SAnalyticsAndDebugging { return injected.log }
    let localStore: LocalStorageProtocol
    
    public init(registrar: RemoteNotificationsRegistrarProtocol,
                navigationRouter: NavigationRoutingProtocol,
                inject: CoreInjectionProtocol,
                companyCoordinatorFactory: CompanyCoordinatorFactoryProtocol,
                companyDocumentsService: F4SCompanyDocumentServiceProtocol,
                companyRepository: F4SCompanyRepositoryProtocol,
                companyService: F4SCompanyServiceProtocol,
                documentUploaderFactory: F4SDocumentUploaderFactoryProtocol,
                emailVerificationModel: F4SEmailVerificationModelProtocol,
                favouritesRepository: F4SFavouritesRepositoryProtocol,
                localStore: LocalStorageProtocol,
                offerProcessingService: F4SOfferProcessingServiceProtocol,
                onboardingCoordinatorFactory: OnboardingCoordinatorFactoryProtocol,
                partnersModel: F4SPartnersModelProtocol,
                placementsRepository: F4SPlacementRepositoryProtocol,
                placementService: F4SPlacementServiceProtocol,
                placementDocumentsServiceFactory: F4SPlacementDocumentsServiceFactoryProtocol,
                messageServiceFactory: F4SMessageServiceFactoryProtocol,
                messageActionServiceFactory: F4SMessageActionServiceFactoryProtocol,
                messageCannedResponsesServiceFactory: F4SCannedMessageResponsesServiceFactoryProtocol,
                recommendationsService: F4SRecommendationServiceProtocol,
                roleService: F4SRoleServiceProtocol,
                tabBarCoordinatorFactory: TabbarCoordinatorFactoryProtocol,
                versionCheckCoordinator: VersionCheckCoordinatorProtocol) {
        
        self.registrar = registrar
        self.injected = inject
        
        self.companyCoordinatorFactory = companyCoordinatorFactory
        self.companyDocumentsService = companyDocumentsService
        self.companyRepository = companyRepository
        self.companyService = companyService
        self.documentUploaderFactory = documentUploaderFactory
        
        self.emailVerificationModel = emailVerificationModel
        self.favouritesRepository = favouritesRepository
        self.localStore = localStore
        self.offerProcessingService = offerProcessingService
        self.partnersModel = partnersModel
        self.placementsRepository = placementsRepository
        
        self.placementService = placementService
        self.placementDocumentsServiceFactory = placementDocumentsServiceFactory
        self.messageServiceFactory = messageServiceFactory
        self.messageActionServiceFactory = messageActionServiceFactory
        self.messageCannedResponsesServiceFactory = messageCannedResponsesServiceFactory
        
        self.onboardingCoordinatorFactory = onboardingCoordinatorFactory
        self.recommendationsService = recommendationsService
        self.roleService = roleService
        self.tabBarCoordinatorFactory = tabBarCoordinatorFactory
        self.versionCheckCoordinator = versionCheckCoordinator
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = navigationRouter.rootViewController
        window.makeKeyAndVisible()

        super.init(parent:nil, navigationRouter: navigationRouter)
        darkModeOptOut(window: window)
        self.injected.appCoordinator = self
        versionCheckCoordinator.parentCoordinator = self
        userNotificationService = UNService(appCoordinator: self)
    }
    
    func darkModeOptOut(window: UIWindow) {
        if #available(iOS 13.0, *) {
            if window.responds(to: #selector(getter: UIView.overrideUserInterfaceStyle)) {
                window.setValue(UIUserInterfaceStyle.light.rawValue, forKey: "overrideUserInterfaceStyle")
            }
        }
    }
    
    override func start() {
        GMSServices.provideAPIKey(GoogleApiKeys.googleApiKey)
        GMSPlacesClient.provideAPIKey(GoogleApiKeys.googleApiKey)
        if launchOptions?[.remoteNotification] == nil {
            performVersionCheck(resultHandler: onVersionCheckResult)
            writeTestError()
        } else {
            startTabBarCoordinator()
        }
    }
    
    func writeTestError() {
        let error: NSError
        switch Config.environment {
        case .staging:
            error = NSError(domain:"com.workfinder.staging", code:406, userInfo: ["env" : "Test error to Staging"])
        case .production:
            error = NSError(domain:"com.workfinder.production", code:408, userInfo: ["env" : "Test error to Production"])
        }
        let log = injected.log
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5) {
            log.notifyError(error, functionName: #function, fileName: #file, lineNumber: #line)
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
        injected.user.uuid = userUuid
        injected.userRepository.save(user: injected.user)
        logStartupInformation(userId: userUuid)
        injected.log.identity(userId: userUuid)
        registrar.registerForRemoteNotifications()
        injected.userStatusService.beginStatusUpdate()
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
    
    private func ensureDeviceIsRegistered(completion: @escaping (F4SUUID)->()) {
        let installationUuidLogic = injected.appInstallationUuidLogic
        installationUuidLogic.ensureDeviceIsRegistered {  [weak self] (result) in
            guard let strongSelf = self else { return }
            switch result {
            case .error(_):
                strongSelf.presentNoNetworkMustRetry(retryOperation: {
                    strongSelf.ensureDeviceIsRegistered(completion: completion)
                })
            case .success(let result):
                guard let anonymousUserUuid = result.uuid else {
                    let error = NSError(domain: "F4S", code: 1, userInfo: [NSLocalizedDescriptionKey: "No uuid returned when registering device"])
                    strongSelf.log.error(error, functionName: #function, fileName: #file, lineNumber: #line)
                    fatalError("registering device failed to obtain uuid")
                }
                completion(anonymousUserUuid)
            }
        }
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
        Installation UUID = \(injected.appInstallationUuidLogic.registeredInstallationUuid!)
        User UUID = \(userId)
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
