import Foundation

public protocol RoutingProtocol {
    var rootViewController: UIViewController { get }
    func present(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?)
    func dismiss(animated: Bool, completion: (() -> Void)?)
}

public protocol NavigationRoutingProtocol : RoutingProtocol {
    var navigationController: UINavigationController { get }
    func push(viewController: UIViewController, animated: Bool)
    func pop(animated: Bool)
    func popToViewController(_ viewController: UIViewController, animated: Bool)
}

public protocol CompanyCoordinatorParentProtocol : CoreInjectionNavigationCoordinatorProtocol {
    func showMessages()
    func showSearch()
}

public protocol F4SDatabaseDownloadManagerProtocol : class {
    var localDatabaseDatestamp: Date? { get }
    func start()
    func registerObserver(_ observer: F4SCompanyDatabaseAvailabilityObserving)
    func removeObserver(_ observer: F4SCompanyDatabaseAvailabilityObserving)
    func ageOfLocalDatabase() -> TimeInterval
    func isLocalDatabaseAvailable() -> Bool
}

public protocol F4SCompanyDatabaseAvailabilityObserving : class {
    func newStagedDatabaseIsAvailable(url: URL)
    func newDatabaseIsDownloading(progress: Double)
}

public protocol F4SUserStatusServiceProtocol {
    var userStatus: F4SUserStatus? { get }
    func beginStatusUpdate()
    func getUserStatus(completion: @escaping (F4SNetworkResult<F4SUserStatus>) -> ())
}

public protocol F4SUserServiceProtocol : class {
    func updateUser(user: F4SUser, completion: @escaping (F4SNetworkResult<F4SUserModel>) -> ())
    func enablePushNotificationForUser(installationUuid: F4SUUID, withDeviceToken: String, completion: @escaping (_ result: F4SNetworkResult<F4SPushNotificationStatus>) -> ())
}

public protocol AppInstallationUuidLogicProtocol : class {
    var registeredInstallationUuid: F4SUUID? { get }
    func ensureDeviceIsRegistered(completion: @escaping (F4SNetworkResult<F4SRegisterDeviceResult>)->())
}

public typealias LaunchOptions = [UIApplication.LaunchOptionsKey: Any]

public protocol CoreInjectionProtocol : class {
    var appInstallationUuidLogic: AppInstallationUuidLogicProtocol { get }
    var launchOptions: LaunchOptions? { get set }
    var user: F4SUser { get set }
    var userService: F4SUserServiceProtocol { get }
    var userStatusService: F4SUserStatusServiceProtocol { get }
    var userRepository: F4SUserRepositoryProtocol { get }
    var databaseDownloadManager: F4SDatabaseDownloadManagerProtocol { get }
    var log: F4SAnalyticsAndDebugging { get }
}

public protocol Coordinating : class {
    
    var parentCoordinator: Coordinating? { get set }
    var uuid: UUID { get }
    var childCoordinators: [UUID: Coordinating] { get set }
    func addChildCoordinator(_ coordinator: Coordinating)
    func removeChildCoordinator(_ coordinator: Coordinating)
    
    func start()
    func childCoordinatorDidFinish(_ coordinator: Coordinating)
}

public extension Coordinating {
    
    func childCoordinatorDidFinish(_ coordinator: Coordinating) {
        removeChildCoordinator(coordinator)
    }
    
    func addChildCoordinator(_ coordinator: Coordinating) {
        childCoordinators[coordinator.uuid] = coordinator
    }
    func removeChildCoordinator(_ coordinator: Coordinating) {
        childCoordinators[coordinator.uuid] = nil
    }
}

public protocol CoreInjectionNavigationCoordinatorProtocol : Coordinating {
    var injected: CoreInjectionProtocol { get }
}

public protocol CompanyCoordinatorProtocol : CoreInjectionNavigationCoordinatorProtocol {}

public protocol CompanyCoordinatorFactoryProtocol {
    func makeCompanyCoordinator(
        parent: CompanyCoordinatorParentProtocol,
        navigationRouter: NavigationRoutingProtocol,
        inject: CoreInjectionProtocol,
        companyUuid: F4SUUID) ->  CompanyCoordinatorProtocol?
    
    func makeCompanyCoordinator(
        parent: CompanyCoordinatorParentProtocol,
        navigationRouter: NavigationRoutingProtocol,
        company: Company,
        inject: CoreInjectionProtocol) -> CompanyCoordinatorProtocol
}
