//
//  CustomNavigationHelper.swift
//  f4s-workexperience
//
//  Created by Andreea Rusu on 26/04/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import Foundation
import UIKit

class CustomNavigationHelper {
    class var sharedInstance: CustomNavigationHelper {
        struct Static {
            static let instance: CustomNavigationHelper = CustomNavigationHelper()
        }
        return Static.instance
    }

    var tabBar: CustomTabBarViewController!
    var mapNavigationController: RotationAwareNavigationController!
    var mapViewController: MapViewController!
    var favouriteNavigationController: RotationAwareNavigationController!
    var favouritesViewController: FavouriteViewController!
    var timelineNavigationController: RotationAwareNavigationController!
    var timelineViewController: TimelineViewController!
    var drawerController: DrawerController?

    init(window: UIWindow? = nil) {
        let optionalDelegateWindow = UIApplication.shared.delegate?.window!!
        guard let window = window ?? optionalDelegateWindow else {
            assert(false, "No window")
            return
        }
        createTabBar()
        window.rootViewController = setUpDrawerController(navigationController: tabBar)
    }
    
    public func navigateToTimeline(threadUuid: F4SUUID?) {
//        if let topViewCtrl = window.rootViewController?.topMostViewController {
//            if let sideMenuViewCtrl = topViewCtrl as? SideMenuViewController {
//                if let centerCtrl = sideMenuViewCtrl.evo_drawerController?.centerViewController as? CustomTabBarViewController {
//                    if let currentTabCtrl = centerCtrl.selectedViewController as? TimelineViewController {
//                        // go to message screen
//                        currentTabCtrl.threadUuid = threadUuid
//                        currentTabCtrl.goToMessageViewCtrl()
//                        return
//                    }
//                    if let currentTabCtrl = centerCtrl.selectedViewController as? UINavigationController {
//                        if let timelineCtrl = currentTabCtrl.topMostViewController as? TimelineViewController {
//                            // go to message screen
//                            timelineCtrl.threadUuid = threadUuid
//                            timelineCtrl.goToMessageViewCtrl()
//                            return
//                        }
//                    }
//                }
//            }
//        }
    }
    
    public func navigateToMap() {
        
    }

    public func navigateToFavourites() {
        
    }
    
    public func navigateToRecommendations(company: Company) {
        
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
        if (drawerController?.evo_drawerController?.visibleLeftDrawerWidth)! > CGFloat(0) {
            return true
        }
        return false
    }
    
    public func completeOnboarding(mapShouldRequestLocation: Bool) {
        UserDefaults.standard.set(false, forKey: UserDefaultsKeys.isFirstLaunch)
        mapViewController.shouldRequestAuthorization = mapShouldRequestLocation
        presentPartnerSelection()
    }
    lazy var partnersModel: PartnersModel = {
        let p = PartnersModel.sharedInstance
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
        createMapViewController(shouldRequestAuthorization: false)
        createFavouritesNavigationController()
        createTimelineNavigationController(threadUUID: nil)
        tabBar = CustomTabBarViewController()
        tabBar.viewControllers = [timelineNavigationController, favouriteNavigationController, mapNavigationController]
    }
    
    private func createTimelineNavigationController(threadUUID: String?) {
        let timelineStoryboard = UIStoryboard(name: "TimelineView", bundle: nil)
        timelineViewController = timelineStoryboard.instantiateViewController(withIdentifier: "timelineViewCtrl") as! TimelineViewController
        timelineViewController.threadUuid = threadUUID
        var timelineBarItem = UITabBarItem(title: "", image: UIImage(named: "timelineIconUnselected")?.withRenderingMode(.alwaysOriginal),
                                           selectedImage: UIImage(named: "timelineIcon")?.withRenderingMode(.alwaysOriginal))
        timelineBarItem = timelineBarItem.tabBarItemShowingOnlyImage()
        timelineNavigationController = RotationAwareNavigationController(rootViewController: timelineViewController)
        timelineNavigationController.tabBarItem = timelineBarItem
    }
    
    private func createFavouritesNavigationController() {
        let favouriteStoryboard = UIStoryboard(name: "Favourite", bundle: nil)
        favouritesViewController = favouriteStoryboard.instantiateViewController(withIdentifier: "FavouriteViewCtrl") as! FavouriteViewController
        var favouriteBarItem = UITabBarItem(title: "", image: UIImage(named: "favouriteIconUnselected")?.withRenderingMode(.alwaysOriginal),
                                            selectedImage: UIImage(named: "favouriteIcon")?.withRenderingMode(.alwaysOriginal))
        favouriteBarItem = favouriteBarItem.tabBarItemShowingOnlyImage()
        favouriteNavigationController = RotationAwareNavigationController(rootViewController: favouritesViewController)
        favouriteNavigationController.tabBarItem = favouriteBarItem
    }
    
    private func createMapViewController(shouldRequestAuthorization: Bool) {
        let mapStoryboard = UIStoryboard(name: "MapView", bundle: nil)
        mapViewController = mapStoryboard.instantiateViewController(withIdentifier: "MapViewCtrl") as! MapViewController
        mapNavigationController = RotationAwareNavigationController(rootViewController: mapViewController)
        mapNavigationController.evo_drawerController?.openDrawerGestureModeMask = .init(rawValue: 0)
        mapViewController.shouldRequestAuthorization = shouldRequestAuthorization
        var mapBarItem = UITabBarItem(title: "", image: UIImage(named: "mapIconUnselected")?.withRenderingMode(.alwaysOriginal),
                                      selectedImage: UIImage(named: "mapIcon")?.withRenderingMode(.alwaysOriginal))
        mapBarItem = mapBarItem.tabBarItemShowingOnlyImage()
        mapNavigationController.tabBarItem = mapBarItem
    }

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

    func presentCoverLetterController(parentCtrl: UIViewController, currentCompany: Company) {
        let coverLetterStoryboard = UIStoryboard(name: "CoverLetter", bundle: nil)
        guard let coverLetterCtrl = coverLetterStoryboard.instantiateViewController(withIdentifier: "CoverLetterViewCtrl") as? CoverLetterViewController else {
            return
        }
        coverLetterCtrl.currentCompany = currentCompany
        let coverLetterNavigationController = RotationAwareNavigationController(rootViewController: coverLetterCtrl)
        parentCtrl.present(coverLetterNavigationController, animated: true, completion: nil)
    }
    
    func presentRecommendationsController(company: Company? = nil) {
        let navCtrl = tabBar.navigationController!
        presentRecommendationsController(navCtrl: navCtrl, company: company)
    }
    
    func presentRecommendationsController(navCtrl: UINavigationController, company: Company? = nil) {
        let recommendationsStoryboard = UIStoryboard(name: "Recommendations", bundle: nil) 
        guard let recommendationsNavController = recommendationsStoryboard.instantiateInitialViewController() as? UINavigationController else {
            return
        }
        guard let recommendationsController = recommendationsNavController.topMostViewController as? RecommendationsViewController else {
            return
        }
        recommendationsController.selectCompany = company
        let noRecommendationsText = "No recommendations yet\n\nAfter you start applying to companies, we will recommend other great companies you may like\n\nGet cracking today!"
        recommendationsController.emptyRecomendationsListText = noRecommendationsText
        navCtrl.present(recommendationsNavController, animated: true, completion: nil)
    }

    func presentContentViewController(navCtrl: UINavigationController, contentType: ContentType) {
        let contentStoryboard = UIStoryboard(name: "Content", bundle: nil)
        guard let contentViewController = contentStoryboard.instantiateViewController(withIdentifier: "ContentViewCtrl") as? ContentViewController else {
            return
        }
        contentViewController.contentType = contentType
        let navigationCtrl = RotationAwareNavigationController(rootViewController: contentViewController)

        navCtrl.present(navigationCtrl, animated: true, completion: nil)
    }

    func presentContentViewController(navCtrl: UINavigationController, contentType: ContentType, url: String) {
        let contentStoryboard = UIStoryboard(name: "Content", bundle: nil)
        guard let contentViewController = contentStoryboard.instantiateViewController(withIdentifier: "ContentViewCtrl") as? ContentViewController else {
            return
        }
        contentViewController.contentType = contentType
        contentViewController.url = url
        let navigationCtrl = RotationAwareNavigationController(rootViewController: contentViewController)

        navCtrl.present(navigationCtrl, animated: true, completion: nil)
    }

    func pushEditCoverLetter(_ navCtrl: UINavigationController, currentTemplate: TemplateEntity) {
        let coverLetterStoryboard = UIStoryboard(name: "EditCoverLetter", bundle: nil)
        guard let ctrl = coverLetterStoryboard.instantiateViewController(withIdentifier: "EditCoverLetterCtrl") as? EditCoverLetterViewController else {
            return
        }
        ctrl.currentTemplate = currentTemplate
        navCtrl.pushViewController(ctrl, animated: true)
    }

    func pushChooseAttributes(_ navController: UINavigationController, currentTemplate: TemplateEntity, attribute: ChooseAttributes) {
        let chooseAttributesStoryboard = UIStoryboard(name: "ChooseAttributes", bundle: nil)
        guard let ctrl = chooseAttributesStoryboard.instantiateViewController(withIdentifier: "ChooseAttributesCtrl") as? ChooseAttributesViewController else {
            return
        }
        ctrl.currentTemplate = currentTemplate
        ctrl.currentAttributeType = attribute
        navController.pushViewController(ctrl, animated: true)
    }

    func pushProcessedMessages(_ navController: UINavigationController, currentCompany: Company) {
        let processedMessagesStoryboard = UIStoryboard(name: "ProcessedMessages", bundle: nil)
        guard let ctrl = processedMessagesStoryboard.instantiateViewController(withIdentifier: "ProcessedMessagesCtrl") as? ProcessedMessagesViewController else {
            return
        }
        ctrl.currentCompany = currentCompany
        navController.pushViewController(ctrl, animated: true)
    }

    func presentCompanyDetailsPopover(parentCtrl: UIViewController, company: Company) {
        guard let popOverVC = UIStoryboard(name: "CompanyDetails", bundle: nil).instantiateViewController(withIdentifier: "CompanyDetailsCtrl") as? CompanyDetailsViewController else {
            return
        }
        popOverVC.company = company
        let popOverVCWithNavCtrl = RotationAwareNavigationController(rootViewController: popOverVC)

        parentCtrl.present(popOverVCWithNavCtrl, animated: true, completion: nil)
    }

    func presentNotificationPopover(parentCtrl: UIViewController, currentCompany: Company) {
        guard let popOverVC = UIStoryboard(name: "NotificationView", bundle: nil).instantiateViewController(withIdentifier: "NotificationCtrl") as? NotificationViewController else {
            return
        }
        popOverVC.currentCompany = currentCompany
        parentCtrl.addChildViewController(popOverVC)
        popOverVC.backgroundPopoverView.frame = parentCtrl.view.frame
        popOverVC.backgroundPopoverView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        parentCtrl.view.addSubview(popOverVC.backgroundPopoverView)

        let popoverNavigationController = UINavigationController(rootViewController: popOverVC)
        popoverNavigationController.modalPresentationStyle = .popover

        let popover = popoverNavigationController.popoverPresentationController
        popover?.canOverlapSourceViewRect = true

        popOverVC.navigationController?.isNavigationBarHidden = true
        popOverVC.preferredContentSize = CGSize(width: popOverVC.view.frame.width - 40, height: popOverVC.contentLabel.frame.size.height + popOverVC.getHeight())

        popover?.sourceView = parentCtrl.view
        popover?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        popover?.sourceRect = CGRect(x: parentCtrl.view.bounds.midX, y: parentCtrl.view.bounds.midY, width: 0, height: 0)
        popover?.delegate = popOverVC as NotificationViewController

        parentCtrl.navigationController?.present(popoverNavigationController, animated: true, completion: nil)
    }

    func presentSuccessExtraInfoPopover(parentCtrl: UIViewController) {
        guard let popOverVC = UIStoryboard(name: "SuccessExtraInfo", bundle: nil).instantiateViewController(withIdentifier: "SuccessExtraInfoCtrl") as? SuccessExtraInfoViewController else {
            return
        }
        parentCtrl.addChildViewController(popOverVC)
        popOverVC.backgroundPopoverView.frame = parentCtrl.view.frame
        popOverVC.backgroundPopoverView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        parentCtrl.view.addSubview(popOverVC.backgroundPopoverView)

        let popoverNavigationController = UINavigationController(rootViewController: popOverVC)
        popoverNavigationController.modalPresentationStyle = .popover

        let popover = popoverNavigationController.popoverPresentationController
        popover?.canOverlapSourceViewRect = true

        popOverVC.navigationController?.isNavigationBarHidden = true
        popOverVC.preferredContentSize = CGSize(width: popOverVC.view.frame.width - 40, height: popOverVC.getHeight())

        popover?.sourceView = parentCtrl.view
        popover?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        popover?.sourceRect = CGRect(x: parentCtrl.view.bounds.midX, y: parentCtrl.view.bounds.midY, width: 0, height: 0)
        popover?.delegate = popOverVC as SuccessExtraInfoViewController

        parentCtrl.navigationController?.present(popoverNavigationController, animated: true, completion: nil)
    }
    
    func pushEmailVerification(navigCtrl: UINavigationController, company: Company) {
        let emailStoryboard = UIStoryboard(name: "F4SEmailVerification", bundle: nil)
        guard let emailController = emailStoryboard.instantiateViewController(withIdentifier: "EmailVerification") as? F4SEmailVerificationViewController else {
            return
        }
        emailController.emailWasVerified = { [weak self] in
            self?.pushExtraInfoViewController(navigCtrl: navigCtrl, company: company)
        }
        navigCtrl.pushViewController(emailController, animated: true)
    }

    func pushExtraInfoViewController(navigCtrl: UINavigationController, company: Company) {
        let extraInfoStoryboard = UIStoryboard(name: "ExtraInfo", bundle: nil)
        guard let extraInfoCtrl = extraInfoStoryboard.instantiateViewController(withIdentifier: "ExtraInfoCtrl") as? ExtraInfoViewController else {
            return
        }
        extraInfoCtrl.currentCompany = company
        navigCtrl.pushViewController(extraInfoCtrl, animated: true)
    }

    func pushMessageController(parentCtrl: UIViewController, threadUuid: String, company: Company, placements: [TimelinePlacement], companies: [Company]) {
        let messageStoryboard = UIStoryboard(name: "Message", bundle: nil)
        guard let messageController = messageStoryboard.instantiateViewController(withIdentifier: "MessageContainerViewCtrl") as? MessageContainerViewController else {
            return
        }
        messageController.threadUuid = threadUuid
        messageController.company = company
        messageController.companies = companies
        messageController.placements = placements
        parentCtrl.navigationController?.pushViewController(messageController, animated: true)
    }

    func presentRatePlacementPopover(parentCtrl: UIViewController, placementUuid: String, ratePlacementProtocol: CustomTabBarViewController? = nil) {
        guard let popOverCtrl = UIStoryboard(name: "RatePlacement", bundle: nil).instantiateViewController(withIdentifier: "RatePlacementCtrl") as? RatePlacementViewController else {
            return
        }
        popOverCtrl.placementUuid = placementUuid
        parentCtrl.addChildViewController(popOverCtrl)
        popOverCtrl.backgroundPopoverView.frame = CGRect(x: 0, y: 0, width: parentCtrl.view.frame.width, height: UIScreen.main.bounds.height)
        popOverCtrl.backgroundPopoverView.backgroundColor = UIColor.black
        popOverCtrl.backgroundPopoverView.alpha = 0.5
        if parentCtrl.parent is CustomTabBarViewController {
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
    
    func presentFavouriteMaximumPopover(parentCtrl: UIViewController) {
        guard let popOverVC = UIStoryboard(name: "FavouritesPopup", bundle: nil).instantiateViewController(withIdentifier: "FavouritesPopupViewCtrl") as? FavouritesPopupViewController else {
            return
        }
        parentCtrl.addChildViewController(popOverVC)
        popOverVC.backgroundPopoverView.frame = parentCtrl.view.frame
        popOverVC.backgroundPopoverView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        parentCtrl.view.addSubview(popOverVC.backgroundPopoverView)
        
        let popoverNavigationController = UINavigationController(rootViewController: popOverVC)
        popoverNavigationController.modalPresentationStyle = .popover
        
        let popover = popoverNavigationController.popoverPresentationController
        popover?.canOverlapSourceViewRect = true
        
        popOverVC.navigationController?.isNavigationBarHidden = true
        popOverVC.preferredContentSize = CGSize(width: popOverVC.view.frame.width - 40, height: popOverVC.contentLabel.frame.size.height + popOverVC.getHeight())
        
        popover?.sourceView = parentCtrl.view
        popover?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        popover?.sourceRect = CGRect(x: parentCtrl.view.bounds.midX, y: parentCtrl.view.bounds.midY, width: 0, height: 0)
        popover?.delegate = popOverVC as FavouritesPopupViewController
        
        parentCtrl.navigationController?.present(popoverNavigationController, animated: true, completion: nil)
    }
}

class RotationAwareNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationBar.tintColor = UIColor(netHex: Colors.white)
        self.navigationBar.barTintColor = UIColor(netHex: Colors.black)

        self.toolbar.tintColor = UIColor(netHex: Colors.white)
        self.toolbar.barTintColor = UIColor(netHex: Colors.black)
    }

    open override var shouldAutorotate: Bool {
        let top = self.topViewController
        return (top?.shouldAutorotate)!
    }
}
