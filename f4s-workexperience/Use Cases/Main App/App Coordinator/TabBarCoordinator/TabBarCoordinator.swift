import UIKit
import WorkfinderCommon
import WorkfinderServices
import WorkfinderUI
import WorkfinderCoordinators
import WorkfinderFavouritesUseCase
import WorkfinderRecommendations
import WorkfinderMessagesUseCase
import WorkfinderOnboardingUseCase

class TabBarCoordinator : TabBarCoordinatorProtocol {
    
    var injected: CoreInjectionProtocol
    
    required init(parent: Coordinating?, navigationRouter: NavigationRoutingProtocol, inject: CoreInjectionProtocol) {
        self.injected = inject
        self.parentCoordinator = parent
    }
    
    var parentCoordinator: Coordinating?
    var uuid: UUID = UUID()
    
    var navigationRouter: NavigationRoutingProtocol?
    var rootViewController: UIViewController!
    var childCoordinators: [UUID : Coordinating] = [:]
    
    static var sharedInstance: TabBarCoordinator!

    var tabBarViewController: TabBarViewController!
    var drawerController: DrawerController?
    var shouldAskOperatingSystemToAllowLocation = false
    
    func start() {
        createTabBar()
        rootViewController = setUpDrawerController(navigationController: tabBarViewController)
        let window = (UIApplication.shared.delegate as? AppDelegate)?.window!
        window!.rootViewController = rootViewController
        window!.makeKeyAndVisible()
        navigateToMostAppropriateInitialTab()
    }
    
    public func navigateToMostAppropriateInitialTab() {
        let shouldLoadTimeline = UserDefaults.standard.value(forKey: UserDefaultsKeys.shouldLoadTimeline) as? Bool ?? false
        if shouldLoadTimeline {
            navigateToTimeline()
        } else {
            navigateToMap()
        }
    }
    
    public func updateBadges() {
        F4SUserStatusService.shared.beginStatusUpdate()
        recommendationsCoordinator.updateBadges()
    }
    
    public func navigateToTimeline() {
        closeMenu { [weak self] (success) in
            guard let strongSelf = self else { return }
            strongSelf.tabBarViewController.selectedIndex = TabIndex.timeline.rawValue
        }
    }

    public func navigateToRecommendations(company: Company? = nil) {
        closeMenu { [weak self] (success) in
            guard let strongSelf = self else { return }
            strongSelf.tabBarViewController.selectedIndex = TabIndex.recommendations.rawValue
        }
    }
    
    public func navigateToFavourites() {
        closeMenu { [weak self] (success) in
            guard let strongSelf = self else { return }
            strongSelf.tabBarViewController.selectedIndex = TabIndex.favourites.rawValue
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

    lazy var partnersModel: F4SPartnersModel = {
        let p = F4SPartnersModel.sharedInstance
        p.showWillProvidePartnerLater = true
        p.getPartners(completed: { (_) in
            return
        })
        return p
    }()
    
    var topNavigationController: UINavigationController {
        return (UIApplication.shared.delegate?.window!!.rootViewController?.topMostViewController?.navigationController)!
    }
    
    private func createTabBar() {

        tabBarViewController = TabBarViewController()
//        let homeNavigationController = homeCoordinator.navigationRouter.navigationController
        let timelineNavigationController = timelineCoordinator.navigationRouter.navigationController
        let recommendationsNavigationController = recommendationsCoordinator.navigationRouter.navigationController
        let favouritesNavigationContoller = favouritesCoordinator.navigationRouter.navigationController
        let searchNavigationController = searchCoodinator.navigationRouter.navigationController
        
        //homeCoordinator.start()
        timelineCoordinator.start()
        recommendationsCoordinator.start()
        favouritesCoordinator.start()
        searchCoodinator.start()
        
        tabBarViewController.viewControllers = [
            //homeNavigationController,
            timelineNavigationController,
            recommendationsNavigationController,
            favouritesNavigationContoller,
            searchNavigationController]
    }
    
    lazy var homeCoordinator: HomeCoordinator = {
        let navigationController = UINavigationController()
        let icon = UIImage(named: "home")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        navigationController.tabBarItem = UITabBarItem(title: "Home", image: icon, selectedImage: nil)
        let router = NavigationRouter(navigationController: navigationController)
        let coordinator = HomeCoordinator(parent: nil, navigationRouter: router, inject: injected)
        addChildCoordinator(coordinator)
        return coordinator
    }()
    
    lazy var timelineCoordinator: TimelineCoordinator = {
        let navigationController = UINavigationController()
        let icon = UIImage(named: "messageOutline")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        navigationController.tabBarItem = UITabBarItem(title: "Messages", image: icon, selectedImage: nil)
        let router = NavigationRouter(navigationController: navigationController)
        let factory = CompanyCoordinatorFactory()
        let companyRepository = F4SCompanyRepository()
        let coordinator = TimelineCoordinator(parent: nil,
                                              navigationRouter: router,
                                              inject: injected,
                                              companyCoordinatorFactory: factory,
                                              companyRepository: companyRepository)
        addChildCoordinator(coordinator)
        return coordinator
    }()
    
    lazy var recommendationsCoordinator: RecommendationsCoordinator = {
        let navigationController = UINavigationController()
        let lightbulbImage = UIImage(named: "light-bulb")
        navigationController.tabBarItem = UITabBarItem(title: "Recommendations", image: lightbulbImage, selectedImage: nil)
        let router = NavigationRouter(navigationController: navigationController)
        let companyRepository = F4SCompanyRepository()
        let coordinator = RecommendationsCoordinator(
            parent: self,
            navigationRouter: router,
            inject: injected,
            companyCoordinatorFactory: companyCoordinatorFactory,
            companyRepository: companyRepository)
        addChildCoordinator(coordinator)
        return coordinator
    }()
    
    lazy var companyCoordinatorFactory: CompanyCoordinatorFactoryProtocol = {
        let factory = CompanyCoordinatorFactory()
        return factory
    }()
    
    lazy var favouritesCoordinator: FavouritesCoordinator = {
        let navigationController = UINavigationController()
        let icon = UIImage(named: "heartOutline")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        navigationController.tabBarItem = UITabBarItem(title: "Favourites", image: icon, selectedImage: nil)
        let router = NavigationRouter(navigationController: navigationController)
        let placementRepository = F4SPlacementRespository()
        let favouritesRepository = F4SFavouritesRepository()
        let companyRepository = F4SCompanyRepository()
        let coordinator = FavouritesCoordinator(parent: self,
                                                navigationRouter: router,
                                                inject: injected,
                                                companyCoordinatorFactory: companyCoordinatorFactory,
                                                placementsRepository: placementRepository,
                                                favouritesRepository: favouritesRepository,
                                                companyRepository: companyRepository)
        addChildCoordinator(coordinator)
        return coordinator
    }()
    
    lazy var searchCoodinator: SearchCoordinator = {
        let navigationController = UINavigationController()
        let searchIcon = UIImage(named: "searchIcon2")?.withRenderingMode(.alwaysTemplate)
        navigationController.tabBarItem = UITabBarItem(title: "Search", image: searchIcon, selectedImage: nil)
        let router = NavigationRouter(navigationController: navigationController)
        let coordinator = SearchCoordinator(parent: self, navigationRouter: router, inject: injected, companyCoordinatorFactory: companyCoordinatorFactory)
        coordinator.shouldAskOperatingSystemToAllowLocation = shouldAskOperatingSystemToAllowLocation
        addChildCoordinator(coordinator)
        return coordinator
    }()

    private func setUpDrawerController(navigationController: UIViewController) -> DrawerController {
        navigationController.restorationIdentifier = "ExampleCenterNavigationControllerRestorationKey"

        let leftSideMenuViewController = SideMenuViewController()

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
        let content = WorkfinderUI().makeWebContentViewController(contentType: contentType, dismissByPopping: true)
        navCtrl.present(content, animated: true, completion: nil)
    }
    
    func showMessages() {
        navigateToTimeline()
    }
    
    func showSearch() {
        navigateToMap()
    }
    
    func updateUnreadMessagesCount(_ count: Int) {
        tabBarViewController.configureTimelineTabBarWithCount(count: count)
    }

}
