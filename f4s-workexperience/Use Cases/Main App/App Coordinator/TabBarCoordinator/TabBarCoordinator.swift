import UIKit
import WorkfinderCommon
import WorkfinderServices
import WorkfinderUI
import WorkfinderCoordinators
import WorkfinderOnboardingUseCase
import WorkfinderApplications
import WorkfinderRecommendationsList
import WorkfinderCompanyDetailsUseCase

class TabBarCoordinator : NSObject, TabBarCoordinatorProtocol {
    var parentCoordinator: Coordinating?
    var appCoordinator: AppCoordinatorProtocol?
    
    let injected: CoreInjectionProtocol
    let companyCoordinatorFactory: CompanyCoordinatorFactoryProtocol
    let interestsRepository: F4SSelectedInterestsRepositoryProtocol
    
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
                  companyCoordinatorFactory: CompanyCoordinatorFactoryProtocol,
                  interestsRepository: F4SSelectedInterestsRepositoryProtocol) {
        self.appCoordinator = parent
        self.parentCoordinator = parent
        self.navigationRouter = navigationRouter
        self.injected = inject
        self.companyCoordinatorFactory = companyCoordinatorFactory
        self.interestsRepository = interestsRepository
    }
    
    func start() {
        createTabBar()
        rootViewController = setUpDrawerController(navigationController: tabBarViewController)
        guard let window = (UIApplication.shared.delegate as? AppDelegate)?.window else { return }
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
        navigateToMostAppropriateInitialTab()
    }
    
    public func navigateToMostAppropriateInitialTab() {
        navigateToMap()
    }
    
    public func updateBadges() {

    }

    public func dispatchRecommendationToSearchTab(uuid: F4SUUID) {
        closeMenu { [weak self] (success) in
            self?.navigateToMap()
            self?.searchCoordinator.processRecommendation(uuid: uuid)
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
            self.tabBarViewController.selectedIndex = TabIndex.map.rawValue
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
    
    lazy var searchCoordinator: SearchCoordinator = {
        let router = TabIndex.map.makeRouter()
        let coordinator = SearchCoordinator(
            parent: self,
            navigationRouter: router,
            inject: injected,
            companyCoordinatorFactory: companyCoordinatorFactory,
            interestsRepository: interestsRepository)
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
    
    lazy var homeCoordinator: HomeCoordinator = {
        let navigationController = UINavigationController()
        let icon = UIImage(named: "home")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        navigationController.tabBarItem = UITabBarItem(title: "Home", image: icon, selectedImage: nil)
        let router = NavigationRouter(navigationController: navigationController)
        let coordinator = HomeCoordinator(parent: nil, navigationRouter: router, inject: injected)
        addChildCoordinator(coordinator)
        return coordinator
    }()

    private func setUpDrawerController(navigationController: UIViewController) -> DrawerController {
        navigationController.restorationIdentifier = "ExampleCenterNavigationControllerRestorationKey"

        let leftSideMenuViewController = SideMenuViewController()
        leftSideMenuViewController.tabBarCoordinator = self
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
    
    func showApplications() {
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
        switch viewController {
        case searchCoordinator.navigationRouter.navigationController:
            log.track(TrackingEvent.makeTabTap(tab: .search))
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
