import UIKit
import WorkfinderCommon
import WorkfinderServices
import WorkfinderUI
import WorkfinderCoordinators
import WorkfinderFavouritesUseCase
import WorkfinderRecommendations
import WorkfinderMessagesUseCase
import WorkfinderOnboardingUseCase

class TabBarCoordinator : NSObject, TabBarCoordinatorProtocol {
    
    let injected: CoreInjectionProtocol
    let companyCoordinatorFactory: CompanyCoordinatorFactoryProtocol
    let companyDocumentsService: F4SCompanyDocumentServiceProtocol
    let companyRepository: F4SCompanyRepositoryProtocol
    let companyService: F4SCompanyServiceProtocol
    let documentUploaderFactory: F4SDocumentUploaderFactoryProtocol
    let favouritesRepository: F4SFavouritesRepositoryProtocol
    let interestsRepository: F4SInterestsRepositoryProtocol
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
    
    var parentCoordinator: Coordinating?
    let uuid: UUID = UUID()
    let navigationRouter: NavigationRoutingProtocol?
    weak var rootViewController: UIViewController!
    
    var childCoordinators: [UUID : Coordinating] = [:]
    
    var tabBarViewController: TabBarViewController!
    var drawerController: DrawerController?
    var shouldAskOperatingSystemToAllowLocation = false
    
    var timelineCoordinator: TimelineCoordinator!
    var recommendationsCoordinator: RecommendationsCoordinator!
    var favouritesCoordinator: FavouritesCoordinator!
    var searchCoordinator: SearchCoordinator!
    
    required init(parent: Coordinating?,
                  navigationRouter: NavigationRoutingProtocol,
                  inject: CoreInjectionProtocol,
                  companyCoordinatorFactory: CompanyCoordinatorFactoryProtocol,
                  companyDocumentsService: F4SCompanyDocumentServiceProtocol,
                  companyRepository: F4SCompanyRepositoryProtocol,
                  companyService: F4SCompanyServiceProtocol,
                  favouritesRepository: F4SFavouritesRepositoryProtocol,
                  documentUploaderFactory: F4SDocumentUploaderFactoryProtocol,
                  interestsRepository: F4SInterestsRepositoryProtocol,
                  offerProcessingService: F4SOfferProcessingServiceProtocol,
                  partnersModel: F4SPartnersModelProtocol,
                  placementsRepository: F4SPlacementRepositoryProtocol,
                  placementService: F4SPlacementServiceProtocol,
                  placementDocumentsServiceFactory: F4SPlacementDocumentsServiceFactoryProtocol,
                  messageServiceFactory: F4SMessageServiceFactoryProtocol,
                  messageActionServiceFactory: F4SMessageActionServiceFactoryProtocol,
                  messageCannedResponsesServiceFactory: F4SCannedMessageResponsesServiceFactoryProtocol,
                  recommendationsService: F4SRecommendationServiceProtocol,
                  roleService: F4SRoleServiceProtocol) {
        self.parentCoordinator = parent
        self.navigationRouter = navigationRouter
        self.injected = inject
        
        self.companyCoordinatorFactory = companyCoordinatorFactory
        self.companyDocumentsService = companyDocumentsService
        self.companyRepository = companyRepository
        self.companyService = companyService
        self.documentUploaderFactory = documentUploaderFactory
        
        self.favouritesRepository = favouritesRepository
        self.interestsRepository = interestsRepository
        self.offerProcessingService = offerProcessingService
        self.partnersModel = partnersModel
        self.placementsRepository = placementsRepository
        
        self.placementService = placementService
        self.placementDocumentsServiceFactory = placementDocumentsServiceFactory
        self.messageServiceFactory = messageServiceFactory
        self.messageActionServiceFactory = messageActionServiceFactory
        self.messageCannedResponsesServiceFactory = messageCannedResponsesServiceFactory
        
        self.recommendationsService = recommendationsService
        self.roleService = roleService
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
        let shouldLoadTimeline = UserDefaults.standard.value(forKey: UserDefaultsKeys.shouldLoadTimeline) as? Bool ?? false
        if shouldLoadTimeline {
            navigateToTimeline()
        } else {
            navigateToMap()
        }
    }
    
    public func updateBadges() {
        injected.userStatusService.beginStatusUpdate()
        recommendationsCoordinator.updateBadges()
    }
    
    public func navigateToTimeline() {
        closeMenu { [weak self] (success) in
            guard let strongSelf = self else { return }
            strongSelf.injected.log.track(event: .messagesTabTap, properties: nil)
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
    
    var topNavigationController: UINavigationController {
        return (UIApplication.shared.delegate?.window!!.rootViewController?.topMostViewController?.navigationController)!
    }
    
    private func createTabBar() {
        
        timelineCoordinator = makeTimelineCoordinator()
        recommendationsCoordinator = makeRecommendationsCoordinator()
        favouritesCoordinator = makeFavouritesCoordinator()
        searchCoordinator = makeSearchCoordinator()
        
        let timelineNavigationController = timelineCoordinator.navigationRouter.navigationController
        let recommendationsNavigationController = recommendationsCoordinator.navigationRouter.navigationController
        let favouritesNavigationContoller = favouritesCoordinator.navigationRouter.navigationController
        let searchNavigationController = searchCoordinator.navigationRouter.navigationController

        timelineCoordinator.start()
        recommendationsCoordinator.start()
        favouritesCoordinator.start()
        searchCoordinator.start()
        
        tabBarViewController = TabBarViewController(userStatusService: injected.userStatusService)
        tabBarViewController.viewControllers = [
            //homeNavigationController,
            timelineNavigationController,
            recommendationsNavigationController,
            favouritesNavigationContoller,
            searchNavigationController]
        tabBarViewController.delegate = self
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
    
    func makeTimelineCoordinator() -> TimelineCoordinator{
        let navigationController = UINavigationController()
        let icon = UIImage(named: "messageOutline")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        navigationController.tabBarItem = UITabBarItem(title: "Messages", image: icon, selectedImage: nil)
        let router = NavigationRouter(navigationController: navigationController)
        let coordinator = TimelineCoordinator(parent: self,
                                              navigationRouter: router,
                                              inject: injected,
                                              messageServiceFactory: messageServiceFactory,
                                              messageActionServiceFactory: messageActionServiceFactory,
                                              messageCannedResponsesServiceFactory: messageCannedResponsesServiceFactory,
                                              offerProcessingService: offerProcessingService,
                                              companyDocumentsService: companyDocumentsService,
                                              placementDocumentsServiceFactory: placementDocumentsServiceFactory,
                                              documentUploaderFactory: documentUploaderFactory,
                                              companyCoordinatorFactory: companyCoordinatorFactory,
                                              companyRepository: companyRepository,
                                              placementService: placementService,
                                              companyService: companyService,
                                              roleService: roleService)
        addChildCoordinator(coordinator)
        return coordinator
    }
    
    func makeRecommendationsCoordinator() -> RecommendationsCoordinator {
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
            companyRepository: companyRepository,
            recommendationsService: recommendationsService)
        addChildCoordinator(coordinator)
        return coordinator
    }
    
    func makeFavouritesCoordinator() -> FavouritesCoordinator {
        let navigationController = UINavigationController()
        let icon = UIImage(named: "heartOutline")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        navigationController.tabBarItem = UITabBarItem(title: "Favourites", image: icon, selectedImage: nil)
        let router = NavigationRouter(navigationController: navigationController)
        let coordinator = FavouritesCoordinator(parent: self,
                                                navigationRouter: router,
                                                inject: injected,
                                                companyCoordinatorFactory: companyCoordinatorFactory,
                                                placementsRepository: placementsRepository,
                                                favouritesRepository: favouritesRepository,
                                                companyRepository: companyRepository)
        addChildCoordinator(coordinator)
        return coordinator
    }
    
    func makeSearchCoordinator() -> SearchCoordinator {
        let navigationController = UINavigationController()
        let searchIcon = UIImage(named: "searchIcon2")?.withRenderingMode(.alwaysTemplate)
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
        let content = WorkfinderUI().makeWebContentViewController(contentType: contentType,
                                                                  dismissByPopping: true,
                                                                  contentService: injected.contentService)
        navCtrl.present(content, animated: true, completion: nil)
    }
    
    func showMessages() {
        navigateToTimeline()
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
        case timelineCoordinator.navigationRouter.navigationController:
            injected.log.track(event: TrackEvent.messagesTabTap, properties: nil)
        case recommendationsCoordinator.navigationRouter.navigationController:
            injected.log.track(event: TrackEvent.recommendationsTabTap, properties: nil)
        case favouritesCoordinator.navigationRouter.navigationController:
            injected.log.track(event: TrackEvent.favouritesTabTap, properties: nil)
        case searchCoordinator.navigationRouter.navigationController:
            injected.log.track(event: TrackEvent.searchTabTap, properties: nil)
        default:
            fatalError("unknown coordinator")
        }
    }
}
