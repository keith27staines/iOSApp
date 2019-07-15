//
//  TabBarCoordinator.swift
//  f4s-workexperience
//
//  Created by Andreea Rusu on 26/04/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import UIKit
import WorkfinderCommon

protocol TabBarCoordinatorProtocol : CoreInjectionNavigationCoordinatorProtocol {
    var shouldAskOperatingSystemToAllowLocation: Bool { get set }
}

class TabBarCoordinator : CoreInjectionNavigationCoordinatorProtocol, TabBarCoordinatorProtocol {
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
            navigateToTimeline(threadUuid: nil)
        } else {
            navigateToMap()
        }
    }
    
    public func updateBadges() {
        F4SUserStatusService.shared.beginStatusUpdate()
        recommendationsCoordinator.viewModel.reload()
    }
    
    public func navigateToTimeline(threadUuid: F4SUUID? = nil) {
        closeMenu { [weak self] (success) in
            guard let strongSelf = self else { return }
            strongSelf.tabBarViewController.selectedIndex = TabIndex.timeline.rawValue
            strongSelf.timelineCoordinator.showThread(threadUuid)
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
    
    func presentPartnerSelection() {
        let vc = UIStoryboard(name: "SelectPartner", bundle: Bundle.main).instantiateInitialViewController() as! PartnerSelectionViewController
        topNavigationController.present(vc, animated: true) {}
    }
    
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
        let coordinator = TimelineCoordinator(parent: nil, navigationRouter: router, inject: injected)
        addChildCoordinator(coordinator)
        return coordinator
    }()
    
    lazy var recommendationsCoordinator: RecommendationsCoordinator = {
        let navigationController = UINavigationController()
        let lightbulbImage = UIImage(named: "light-bulb")
        navigationController.tabBarItem = UITabBarItem(title: "Recommendations", image: lightbulbImage, selectedImage: nil)
        let router = NavigationRouter(navigationController: navigationController)
        let coordinator = RecommendationsCoordinator(parent: nil, navigationRouter: router, inject: injected)
        addChildCoordinator(coordinator)
        return coordinator
    }()
    
    lazy var favouritesCoordinator: FavouritesCoordinator = {
        let navigationController = UINavigationController()
        let icon = UIImage(named: "heartOutline")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        navigationController.tabBarItem = UITabBarItem(title: "Favourites", image: icon, selectedImage: nil)
        let router = NavigationRouter(navigationController: navigationController)
        let coordinator = FavouritesCoordinator(parent: nil, navigationRouter: router, inject: injected)
        addChildCoordinator(coordinator)
        return coordinator
    }()
    
    lazy var searchCoodinator: SearchCoordinator = {
        let navigationController = UINavigationController()
        let searchIcon = UIImage(named: "searchIcon2")?.withRenderingMode(.alwaysTemplate)
        navigationController.tabBarItem = UITabBarItem(title: "Search", image: searchIcon, selectedImage: nil)
        let router = NavigationRouter(navigationController: navigationController)
        let coordinator = SearchCoordinator(parent: nil, navigationRouter: router, inject: injected)
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
        
    func presentRecommendationsController(from navCtrl: UINavigationController, company: Company? = nil) {
        let recommendationsStoryboard = UIStoryboard(name: "Recommendations", bundle: nil) 
        guard let recommendationsNavController = recommendationsStoryboard.instantiateInitialViewController() as? UINavigationController else {
            return
        }
        guard let recommendationsController = recommendationsNavController.topMostViewController as? RecommendationsListViewController else {
            return
        }
        recommendationsController.selectCompany = company
        let noRecommendationsText = "No recommendations yet\n\nAfter you start applying to companies, we will recommend other great companies you may like\n\nGet cracking today!"
        recommendationsController.emptyRecomendationsListText = noRecommendationsText
        navCtrl.present(recommendationsNavController, animated: true, completion: nil)
    }
    
    func presentContentViewController(navCtrl: UINavigationController, contentType: F4SContentType) {
        let contentStoryboard = UIStoryboard(name: "Content", bundle: nil)
        guard let contentViewController = contentStoryboard.instantiateViewController(withIdentifier: "ContentViewCtrl") as? ContentViewController else {
            return
        }
        contentViewController.contentType = contentType
        let navigationCtrl = RotationAwareNavigationController(rootViewController: contentViewController)

        navCtrl.present(navigationCtrl, animated: true, completion: nil)
    }

    func presentContentViewController(navCtrl: UINavigationController, contentType: F4SContentType, url: String) {
        let contentStoryboard = UIStoryboard(name: "Content", bundle: nil)
        guard let contentViewController = contentStoryboard.instantiateViewController(withIdentifier: "ContentViewCtrl") as? ContentViewController else {
            return
        }
        contentViewController.contentType = contentType
        contentViewController.url = url
        let navigationCtrl = RotationAwareNavigationController(rootViewController: contentViewController)

        navCtrl.present(navigationCtrl, animated: true, completion: nil)
    }
    
    func presentRatePlacementPopover(parentCtrl: UIViewController, placementUuid: String, ratePlacementProtocol: TabBarViewController? = nil) {
        guard let popOverCtrl = UIStoryboard(name: "RatePlacement", bundle: nil).instantiateViewController(withIdentifier: "RatePlacementCtrl") as? RatePlacementViewController else {
            return
        }
        popOverCtrl.placementUuid = placementUuid
        parentCtrl.addChild(popOverCtrl)
        popOverCtrl.backgroundPopoverView.frame = CGRect(x: 0, y: 0, width: parentCtrl.view.frame.width, height: UIScreen.main.bounds.height)
        popOverCtrl.backgroundPopoverView.backgroundColor = UIColor.black
        popOverCtrl.backgroundPopoverView.alpha = 0.5
        if parentCtrl.parent is TabBarViewController {
            parentCtrl.parent?.view.addSubview(popOverCtrl.backgroundPopoverView)
        } else {
            if let navigCtrl = parentCtrl.navigationController {
                navigCtrl.view.addSubview(popOverCtrl.backgroundPopoverView)
            } else {
                parentCtrl.view.addSubview(popOverCtrl.backgroundPopoverView)
            }
        }
        if ratePlacementProtocol != nil {
            popOverCtrl.ratePlacementProtocol = ratePlacementProtocol
        }

        let popoverNavigationController = UINavigationController(rootViewController: popOverCtrl)
        popoverNavigationController.modalPresentationStyle = .popover

        let popover = popoverNavigationController.popoverPresentationController
        popover?.canOverlapSourceViewRect = true

        popOverCtrl.navigationController?.isNavigationBarHidden = true
        popOverCtrl.preferredContentSize = CGSize(width: popOverCtrl.view.frame.width - 40, height: popOverCtrl.getHeight())

        popover?.sourceView = parentCtrl.view
        popover?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        popover?.sourceRect = CGRect(x: parentCtrl.view.bounds.midX, y: parentCtrl.view.bounds.midY, width: 0, height: 0)
        popover?.delegate = popOverCtrl

        if let navigCtrl = parentCtrl.navigationController {
            navigCtrl.present(popoverNavigationController, animated: true, completion: nil)
        } else {
            parentCtrl.present(popoverNavigationController, animated: true, completion: nil)
        }
    }
}
