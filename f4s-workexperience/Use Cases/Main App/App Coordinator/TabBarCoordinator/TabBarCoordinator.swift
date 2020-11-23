import UIKit
import WorkfinderCommon
import WorkfinderServices
import WorkfinderUI
import WorkfinderCoordinators
import WorkfinderOnboardingUseCase
import WorkfinderApplications
import WorkfinderRecommendationsList
import WorkfinderCompanyDetailsUseCase
import WorkfinderHome

class TabBarCoordinator : NSObject, TabBarCoordinatorProtocol {
    var parentCoordinator: Coordinating?
    var appCoordinator: AppCoordinatorProtocol?
    
    let injected: CoreInjectionProtocol
    let companyCoordinatorFactory: CompanyCoordinatorFactoryProtocol
    
    let uuid: UUID = UUID()
    let navigationRouter: NavigationRoutingProtocol?
    weak var rootViewController: UIViewController!
    
    var childCoordinators: [UUID : Coordinating] = [:]
    
    var tabBarViewController: TabBarViewController!
    var drawerController: DrawerController?
    var shouldAskOperatingSystemToAllowLocation = false
    
    required init(parent: AppCoordinatorProtocol?,
                  navigationRouter: NavigationRoutingProtocol,
                  inject: CoreInjectionProtocol,
                  companyCoordinatorFactory: CompanyCoordinatorFactoryProtocol) {
        self.appCoordinator = parent
        self.parentCoordinator = parent
        self.navigationRouter = navigationRouter
        self.injected = inject
        self.companyCoordinatorFactory = companyCoordinatorFactory
    }
    
    func start() {
        createTabBar()
        rootViewController = setUpDrawerController(navigationController: tabBarViewController)
        guard let window = (UIApplication.shared.delegate as? AppDelegate)?.window else { return }
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
        navigateToMostAppropriateInitialTab()
    }
    
    private var recommendationsService: RecommendationsServiceProtocol?
    public func navigateToMostAppropriateInitialTab() {
        guard injected.userRepository.loadUser().candidateUuid != nil else {
            navigateToMap()
            return
        }
        recommendationsService = RecommendationsService(networkConfig: injected.networkConfig)
        recommendationsService?.fetchRecommendations { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let recommendations):
                if recommendations.count == 0 {
                    self.navigateToMap()
                } else {
                    self.navigateToRecommendations()
                    self.appCoordinator?.requestPushNotifications(from:self.topNavigationController)
                }
            case .failure(_):
                self.navigateToMap()
            }
        }
        
    }
    
    public func updateBadges() {

    }

    public func dispatchRecommendationToSearchTab(uuid: F4SUUID) {
        closeMenu { [weak self] (success) in
            self?.navigateToMap()
            self?.homeCoordinator.processRecommendation(uuid: uuid)
        }
    }
    
    public func dispatchProjectViewRequest(_ projectUuid: F4SUUID, applicationSource: ApplicationSource) {
        closeMenu() { [ weak self]  (success) in
            guard let self = self else { return }
            self.tabBarViewController.selectedIndex = TabIndex.recommendations.rawValue
            DispatchQueue.main.async {
                self.recommendationsCoordinator.processProjectViewRequest(
                    projectUuid,
                    applicationSource: applicationSource)
            }
        }
    }
    
    public func navigateToApplications() {
        closeMenu() { [ weak self]  (success) in
            guard let self = self else { return }
            self.tabBarViewController.selectedIndex = TabIndex.applications.rawValue
        }
    }
    
    public func navigateToRecommendations() {
        closeMenu() { [ weak self]  (success) in
            guard let self = self else { return }
            self.tabBarViewController.selectedIndex = TabIndex.recommendations.rawValue
        }
    }
    
    public func navigateToMap() {
        closeMenu { [weak self] (success) in
            guard let self = self else { return }
            self.tabBarViewController.selectedIndex = TabIndex.home.rawValue
        }
    }
    
    public func topMostViewController() -> UIViewController? {
        let vc = drawerController?.topMostViewController
        return vc
    }
    
    public func openMenu(completion: ((Bool) -> ())? = nil) {
        if isMenuVisible() {
            completion?(true)
        } else {
            toggleMenu(completion: completion)
        }
    }
    
    public func toggleMenu(completion: ((Bool) -> ())? = nil) {
        drawerController?.toggleLeftDrawerSide(animated: true, completion: completion)
    }
    
    public func closeMenu(completion: ((Bool) -> ())? = nil) {
        if isMenuVisible() {
            toggleMenu(completion: completion)
        } else {
            completion?(true)
        }
    }
    
    public func isMenuVisible() -> Bool {
        if (drawerController?.visibleLeftDrawerWidth)! > CGFloat(0) {
            return true
        }
        return false
    }
    
    var topNavigationController: UINavigationController {
        return (UIApplication.shared.delegate!.window!!.rootViewController?.topMostViewController?.navigationController)!
    }
    
    private func createTabBar() {
        tabBarViewController = TabBarViewController()
        var tabViewControllers = [UIViewController]()
        for tab in TabIndex.allCases {
            let coordinator = tab.tabCoordinator(from: self)
            let controller = coordinator.navigationRouter.navigationController
            coordinator.start()
            tabViewControllers.append(controller)
        }
        tabBarViewController.viewControllers = tabViewControllers
        tabBarViewController.delegate = self
    }
    
    lazy var applicationsCoordinator: ApplicationsCoordinator = {
        let router = TabIndex.applications.makeRouter()
        let coordinator = ApplicationsCoordinator(parent: nil, navigationRouter: router, inject: injected)
        addChildCoordinator(coordinator)
        return coordinator
    }()
    
    lazy var homeCoordinator: HomeCoordinator = {
        let router = TabIndex.home.makeRouter()
        let coordinator = HomeCoordinator(
            parent: self,
            navigationRouter: router,
            inject: injected,
            companyCoordinatorFactory: companyCoordinatorFactory
        )
        coordinator.shouldAskOperatingSystemToAllowLocation = shouldAskOperatingSystemToAllowLocation
        addChildCoordinator(coordinator)
        return coordinator
    }()
    
    lazy var recommendationsCoordinator: RecommendationsCoordinator = {
        let router = TabIndex.recommendations.makeRouter()
        let coordinator = RecommendationsCoordinator(parent: nil, navigationRouter: router, inject: injected, navigateToSearch: self.navigateToMap, navigateToApplications: self.navigateToApplications)
        coordinator.onRecommendationSelected = { uuid in
            self.dispatchRecommendationToSearchTab(uuid: uuid)
        }
        addChildCoordinator(coordinator)
        return coordinator
    }()

    private func setUpDrawerController(navigationController: UIViewController) -> DrawerController {
        navigationController.restorationIdentifier = "ExampleCenterNavigationControllerRestorationKey"

        let leftSideMenuViewController = SideMenuViewController()
        leftSideMenuViewController.tabBarCoordinator = self
        leftSideMenuViewController.appCoordinator = appCoordinator
        leftSideMenuViewController.log = injected.log

        let leftSideNavController = UINavigationController(rootViewController: leftSideMenuViewController)
        leftSideNavController.restorationIdentifier = "ExampleLeftNavigationControllerRestorationKey"

        drawerController = DrawerController(centerViewController: navigationController, leftDrawerViewController: leftSideNavController, rightDrawerViewController: nil)
        drawerController!.showsShadows = true

        drawerController!.restorationIdentifier = "Drawer"
        drawerController!.maximumRightDrawerWidth = 200.0
        drawerController!.maximumLeftDrawerWidth = UIScreen.main.bounds.width - 30
        drawerController!.openDrawerGestureModeMask = .all
        drawerController!.closeDrawerGestureModeMask = .all
        drawerController!.drawerVisualStateBlock = { drawerController, drawerSide, percentVisible in
            let block = ExampleDrawerVisualStateManager.sharedManager.drawerVisualStateBlockForDrawerSide(drawerSide: drawerSide)
            block?(drawerController, drawerSide, percentVisible)
        }
        
        return drawerController!
    }
    
    func presentHiddenDebugController(parentCtrl: UIViewController) {
        let debugStoryboard = UIStoryboard(name: "Debug", bundle: nil)
        guard let navigationController = debugStoryboard.instantiateInitialViewController() else {
            return
        }
        parentCtrl.present(navigationController, animated: true, completion: nil)
    }
    
    func showApplications(uuid: F4SUUID?) {
        navigateToApplications()
    }
    
    func showSearch() {
        navigateToMap()
    }
    
    func updateUnreadMessagesCount(_ count: Int) {
        tabBarViewController.configureTimelineTabBarWithCount(count: count)
    }

}

extension TabBarCoordinator: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let log = injected.log
        drawerController!.openDrawerGestureModeMask = .all
        drawerController!.closeDrawerGestureModeMask = .all
        switch viewController {
        case homeCoordinator.navigationRouter.navigationController:
            log.track(TrackingEvent.makeTabTap(tab: .search))
            drawerController!.openDrawerGestureModeMask = .panningNavigationBar
            drawerController!.closeDrawerGestureModeMask = .all
        case applicationsCoordinator.navigationRouter.navigationController:
            log.track(TrackingEvent.makeTabTap(tab: .applications))
        case recommendationsCoordinator.navigationRouter.navigationController:
            appCoordinator?.requestPushNotifications(from: viewController)
            log.track(TrackingEvent.makeTabTap(tab: .recommendations))
        default:
            fatalError("unknown coordinator")
        }
    }
}

fileprivate extension TrackingEvent {
    enum TabName: String {
        case applications
        case recommendations
        case notifications
        case search
    }
    static func makeTabTap(tab: TabName) -> TrackingEvent {
        TrackingEvent(
            type: .tabTap,
            additionalProperties: ["navigation_item": tab.rawValue]
        )
    }
}
