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
import WorkfinderCandidateProfile
import WorkfinderNPS

class TabBarCoordinator : NSObject, TabBarCoordinatorProtocol {
    
    var parentCoordinator: Coordinating?
    var appCoordinator: AppCoordinatorProtocol?
    
    let injected: CoreInjectionProtocol
    let companyCoordinatorFactory: CompanyCoordinatorFactoryProtocol
    
    let uuid: UUID = UUID()
    let navigationRouter: NavigationRoutingProtocol
    weak var rootViewController: UIViewController!
    
    var childCoordinators: [UUID : Coordinating] = [:]
    
    var tabBarViewController: TabBarViewController!
    
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
        rootViewController = tabBarViewController
        guard let window = (UIApplication.shared.delegate as? AppDelegate)?.window else { return }
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
        switchToTab(.home)
    }
    
    public func updateBadges() {

    }
    
    public func switchToTab(_ tab: TabIndex) {
        tabBarViewController.selectedIndex = tab.rawValue
    }
    
    func routeApplication(placementUuid: F4SUUID?, appSource: AppSource) {
        guard let uuid = placementUuid else { return }
        switchToTab(.applications)
        applicationsCoordinator.routeToApplication(uuid, appSource: appSource)
    }
    
    public func routeRecommendationForAssociation(recommendationUuid: F4SUUID, appSource: AppSource) {
        switchToTab(.home)
        homeCoordinator.processRecommendedAssociation(recommendationUuid: recommendationUuid, source: appSource)
    }
    
    public func routeReview(reviewUuid: F4SUUID, appSource: AppSource, queryItems: [String : String]) {
        guard let token = queryItems.first(where: { itemAndValue in
            itemAndValue.key == "access_token"
        })?.value else { return }
        let scoreString = queryItems.first { itemAndValue in
            itemAndValue.key == "score"
        }?.value
        let score = Int(scoreString ?? "")
        let coordinator = WorkfinderNPSCoordinator(
            parent: self,
            navigationRouter: navigationRouter ,
            inject: injected,
            npsUuid: reviewUuid,
            accessToken: token,
            score: score
        )
        addChildCoordinator(coordinator)
        coordinator.start()
    }
    
    public func routeProject(projectUuid: F4SUUID, appSource: AppSource) {
        tabBarViewController.selectedIndex = TabIndex.recommendations.rawValue
        DispatchQueue.main.async { [weak self] in
            self?.recommendationsCoordinator.processProjectViewRequest(
                projectUuid,
                appSource: appSource)
        }
    }
    
    func routeLiveProjects(appSource: AppSource) {
        tabBarViewController.selectedIndex = TabIndex.home.rawValue
    }
    
    public func topMostViewController() -> UIViewController? {
        let vc = rootViewController.topMostViewController
        return vc
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
            companyCoordinatorFactory: companyCoordinatorFactory,
            tabNavigator: self
        )
        addChildCoordinator(coordinator)
        return coordinator
    }()
    
    lazy var recommendationsCoordinator: RecommendationsCoordinator = {
        let router = TabIndex.recommendations.makeRouter()
        let coordinator = RecommendationsCoordinator(
            parent: nil,
            navigationRouter: router,
            inject: injected,
            switchToTab: { [weak self] tab in self?.switchToTab(tab) }
        )
        addChildCoordinator(coordinator)
        return coordinator
    }()
    
    lazy var accountCoordinator: AccountCoordinator = {
        let router = TabIndex.account.makeRouter()
        let coordinator = AccountCoordinator(
            parent: nil,
            navigationRouter: router,
            inject: injected,
            switchToTab: { [weak self] tab in self?.switchToTab(tab) }
        )
        addChildCoordinator(coordinator)
        return coordinator
    }()
    
    func presentHiddenDebugController(parentCtrl: UIViewController) {
        let debugStoryboard = UIStoryboard(name: "Debug", bundle: nil)
        guard let navigationController = debugStoryboard.instantiateInitialViewController() else {
            return
        }
        parentCtrl.present(navigationController, animated: true, completion: nil)
    }
    
    func updateUnreadMessagesCount(_ count: Int) {
        tabBarViewController.configureTimelineTabBarWithCount(count: count)
    }

}

extension TabBarCoordinator: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let log = injected.log
        switch viewController {
        case homeCoordinator.navigationRouter.navigationController:
            log.track(.tab_tap(tabName: "home"))
        case applicationsCoordinator.navigationRouter.navigationController:
            log.track(.tab_tap(tabName: "applications"))
        case recommendationsCoordinator.navigationRouter.navigationController:
            appCoordinator?.requestPushNotifications(from: viewController, completion: {
                
            })
            log.track(.tab_tap(tabName: "recommendations"))
        case accountCoordinator.navigationRouter.navigationController:
            log.track(.tab_tap(tabName: "account"))
            
        default:
            fatalError("unknown coordinator")
        }
    }
}
