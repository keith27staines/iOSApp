import UIKit
import WorkfinderCommon
import WorkfinderServices
import WorkfinderUI
import WorkfinderCoordinators
import WorkfinderOnboardingUseCase
import WorkfinderApplications

class TabBarCoordinator : NSObject, TabBarCoordinatorProtocol {
    
    let injected: CoreInjectionProtocol
    let companyCoordinatorFactory: CompanyCoordinatorFactoryProtocol
    let interestsRepository: F4SInterestsRepositoryProtocol
    
    var parentCoordinator: Coordinating?
    let uuid: UUID = UUID()
    let navigationRouter: NavigationRoutingProtocol?
    weak var rootViewController: UIViewController!
    
    var childCoordinators: [UUID : Coordinating] = [:]
    
    var tabBarViewController: TabBarViewController!
    var drawerController: DrawerController?
    var shouldAskOperatingSystemToAllowLocation = false
    var searchCoordinator: SearchCoordinator!
    
    required init(parent: Coordinating?,
                  navigationRouter: NavigationRoutingProtocol,
                  inject: CoreInjectionProtocol,
                  companyCoordinatorFactory: CompanyCoordinatorFactoryProtocol,
                  interestsRepository: F4SInterestsRepositoryProtocol) {
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

    public func navigateToRecommendations() {
//        closeMenu { [weak self] (success) in
//            guard let strongSelf = self else { return }
//            strongSelf.tabBarViewController.selectedIndex = TabIndex.recommendations.rawValue
//        }
    }
    
    public func navigateToFavourites() {
//        closeMenu { [weak self] (success) in
//            guard let strongSelf = self else { return }
//            strongSelf.tabBarViewController.selectedIndex = TabIndex.favourites.rawValue
//        }
    }
    
    public func navigateToApplications() {
        closeMenu() { [ weak self]  (success) in
            guard let strongSelf = self else { return }
            strongSelf.tabBarViewController.selectedIndex = TabIndex.applications.rawValue
        }
    }
    
    public func navigateToMap() {
        closeMenu { [weak self] (success) in
            guard let strongSelf = self else { return }
            strongSelf.tabBarViewController.selectedIndex = TabIndex.map.rawValue
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
        injected.log.track(event: .sideMenuToggle, properties: nil)
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
        return (UIApplication.shared.delegate?.window!!.rootViewController?.topMostViewController?.navigationController)!
    }
    
    private func createTabBar() {
        
        searchCoordinator = makeSearchCoordinator()
        
        let searchNavigationController = searchCoordinator.navigationRouter.navigationController
        let applicationsNavigationController = applicationsCoordinator.navigationRouter.navigationController
        searchCoordinator.start()
        applicationsCoordinator.start()
        tabBarViewController = TabBarViewController()
        tabBarViewController.viewControllers = [
            applicationsNavigationController,
            searchNavigationController]
        tabBarViewController.delegate = self
    }
    
    lazy var applicationsCoordinator: ApplicationsCoordinator = {
        let navigationController = UINavigationController()
        let icon = UIImage(named: "applications")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        navigationController.tabBarItem = UITabBarItem(title: "Applications", image: icon, selectedImage: nil)
        let router = NavigationRouter(navigationController: navigationController)
        let coordinator = ApplicationsCoordinator(parent: nil, navigationRouter: router, inject: injected)
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
    
    func makeSearchCoordinator() -> SearchCoordinator {
        let navigationController = UINavigationController()
        let searchIcon = UIImage(named: "searchIcon")?.withRenderingMode(.alwaysTemplate)
        navigationController.tabBarItem = UITabBarItem(title: "Search", image: searchIcon, selectedImage: nil)
        let router = NavigationRouter(navigationController: navigationController)
        let coordinator = SearchCoordinator(
            parent: self,
            navigationRouter: router,
            inject: injected,
            companyCoordinatorFactory: companyCoordinatorFactory,
            interestsRepository: interestsRepository)
        coordinator.shouldAskOperatingSystemToAllowLocation = shouldAskOperatingSystemToAllowLocation
        addChildCoordinator(coordinator)
        return coordinator
    }

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
    
    func presentContentViewController(navCtrl: UINavigationController, contentType: F4SContentType) {
        let content = WorkfinderUI().makeWebContentViewController(
            contentType: contentType,
            dismissByPopping: true)
        navCtrl.present(content, animated: true, completion: nil)
    }
    
    func showApplications() {
        navigateToApplications()
    }
    
    func showSearch() {
        navigateToMap()
    }
    
    func showRecommendations() {
        navigateToRecommendations()
    }
    
    func updateUnreadMessagesCount(_ count: Int) {
        tabBarViewController.configureTimelineTabBarWithCount(count: count)
    }

}

extension TabBarCoordinator: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        switch viewController {
        case searchCoordinator.navigationRouter.navigationController:
            injected.log.track(event: TrackEvent.searchTabTap, properties: nil)
        case applicationsCoordinator.navigationRouter.navigationController:
            injected.log.track(event: TrackEvent.applicationsTabTap, properties: nil)
        default:
            fatalError("unknown coordinator")
        }
    }
}
