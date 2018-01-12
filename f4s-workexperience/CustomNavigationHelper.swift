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

    var drawerController: DrawerController?

    init() {
    }

    func moveToMainCtrl(window: UIWindow) {
        if let isFirstLaunch = UserDefaults.standard.value(forKey: UserDefaultsKeys.isFirstLaunch) {
            if !(isFirstLaunch as! Bool) {
                if let shouldLoadTimeline = UserDefaults.standard.value(forKey: UserDefaultsKeys.shouldLoadTimeline) {
                    if shouldLoadTimeline as! Bool {
                        moveToTimelineCtrl(window: window)
                        return
                    }
                }
                moveToMapCtrl(window: window, shouldRequestAuthorization: false)
                return
            }
        }
        guard let ctrl = window.rootViewController?.topMostViewController as? OnboardingViewController else {
            return
        }
        ctrl.hideOnboardingControls = false
    }

    func moveToMapCtrl(window: UIWindow, shouldRequestAuthorization: Bool) {
        let mapStoryboard = UIStoryboard(name: "MapView", bundle: nil)
        guard let mapCtrl = mapStoryboard.instantiateViewController(withIdentifier: "MapViewCtrl") as? MapViewController else {
            return
        }
        let mapNavigationController = RotationAwareNavigationController(rootViewController: mapCtrl)
        mapNavigationController.evo_drawerController?.openDrawerGestureModeMask = .init(rawValue: 0)
        mapCtrl.shouldRequestAuthorization = shouldRequestAuthorization
        
        let favouriteStoryboard = UIStoryboard(name: "Favourite", bundle: nil)
        guard let favouriteCtrl = favouriteStoryboard.instantiateViewController(withIdentifier: "FavouriteViewCtrl") as? FavouriteViewController else {
            return
        }
        let favouriteNavigationController = RotationAwareNavigationController(rootViewController: favouriteCtrl)

        let timelineStoryboard = UIStoryboard(name: "TimelineView", bundle: nil)
        guard let timelineCtrl = timelineStoryboard.instantiateViewController(withIdentifier: "timelineViewCtrl") as? TimelineViewController else {
            return
        }
        let timelineNavigationController = RotationAwareNavigationController(rootViewController: timelineCtrl)

        var mapBarItem = UITabBarItem(title: "", image: UIImage(named: "mapIconUnselected")?.withRenderingMode(.alwaysOriginal),
                                      selectedImage: UIImage(named: "mapIcon")?.withRenderingMode(.alwaysOriginal))
        mapBarItem = mapBarItem.tabBarItemShowingOnlyImage()
        
        var favouriteBarItem = UITabBarItem(title: "", image: UIImage(named: "favouriteIconUnselected")?.withRenderingMode(.alwaysOriginal),
                                      selectedImage: UIImage(named: "favouriteIcon")?.withRenderingMode(.alwaysOriginal))
        favouriteBarItem = favouriteBarItem.tabBarItemShowingOnlyImage()

        var timelineBarItem = UITabBarItem(title: "", image: UIImage(named: "timelineIconUnselected")?.withRenderingMode(.alwaysOriginal),
                                           selectedImage: UIImage(named: "timelineIcon")?.withRenderingMode(.alwaysOriginal))
        timelineBarItem = timelineBarItem.tabBarItemShowingOnlyImage()

        mapNavigationController.tabBarItem = mapBarItem
        favouriteNavigationController.tabBarItem = favouriteBarItem
        timelineNavigationController.tabBarItem = timelineBarItem
        let tabBar = CustomTabBarViewController()
        tabBar.viewControllers = [timelineNavigationController, favouriteNavigationController, mapNavigationController]

        tabBar.selectedIndex = 2

        window.rootViewController = setUpDrawerController(navigationController: tabBar)
    }

    func moveToTimelineCtrl(window: UIWindow, threadUuid: String = "") {
        let mapStoryboard = UIStoryboard(name: "MapView", bundle: nil)
        guard let mapCtrl = mapStoryboard.instantiateViewController(withIdentifier: "MapViewCtrl") as? MapViewController else {
            return
        }
        let mapNavigationController = RotationAwareNavigationController(rootViewController: mapCtrl)
        mapNavigationController.evo_drawerController?.openDrawerGestureModeMask = .init(rawValue: 0)
        mapCtrl.shouldRequestAuthorization = false
        
        let favouriteStoryboard = UIStoryboard(name: "Favourite", bundle: nil)
        guard let favouriteCtrl = favouriteStoryboard.instantiateViewController(withIdentifier: "FavouriteViewCtrl") as? FavouriteViewController else {
            return
        }
        let favouriteNavigationController = RotationAwareNavigationController(rootViewController: favouriteCtrl)

        let timelineStoryboard = UIStoryboard(name: "TimelineView", bundle: nil)
        guard let timelineCtrl = timelineStoryboard.instantiateViewController(withIdentifier: "timelineViewCtrl") as? TimelineViewController else {
            return
        }
        if !threadUuid.isEmpty {
            timelineCtrl.threadUuid = threadUuid
        }
        let timelineNavigationController = RotationAwareNavigationController(rootViewController: timelineCtrl)

        var mapBarItem = UITabBarItem(title: "", image: UIImage(named: "mapIconUnselected")?.withRenderingMode(.alwaysOriginal),
                                      selectedImage: UIImage(named: "mapIcon")?.withRenderingMode(.alwaysOriginal))
        mapBarItem = mapBarItem.tabBarItemShowingOnlyImage()
        
        var favouriteBarItem = UITabBarItem(title: "", image: UIImage(named: "favouriteIconUnselected")?.withRenderingMode(.alwaysOriginal),
                                            selectedImage: UIImage(named: "favouriteIcon")?.withRenderingMode(.alwaysOriginal))
        favouriteBarItem = favouriteBarItem.tabBarItemShowingOnlyImage()

        var timelineBarItem = UITabBarItem(title: "", image: UIImage(named: "timelineIconUnselected")?.withRenderingMode(.alwaysOriginal),
                                           selectedImage: UIImage(named: "timelineIcon")?.withRenderingMode(.alwaysOriginal))
        timelineBarItem = timelineBarItem.tabBarItemShowingOnlyImage()

        mapNavigationController.tabBarItem = mapBarItem
        favouriteNavigationController.tabBarItem = favouriteBarItem
        timelineNavigationController.tabBarItem = timelineBarItem
        let tabBar = CustomTabBarViewController()
        tabBar.viewControllers = [timelineNavigationController, favouriteNavigationController, mapNavigationController]

        tabBar.selectedIndex = 0

        window.rootViewController = setUpDrawerController(navigationController: tabBar)
    }
    
    
    func moveToFavouriteCtrl(window: UIWindow) {
        let mapStoryboard = UIStoryboard(name: "MapView", bundle: nil)
        guard let mapCtrl = mapStoryboard.instantiateViewController(withIdentifier: "MapViewCtrl") as? MapViewController else {
            return
        }
        let mapNavigationController = RotationAwareNavigationController(rootViewController: mapCtrl)
        mapNavigationController.evo_drawerController?.openDrawerGestureModeMask = .init(rawValue: 0)
        mapCtrl.shouldRequestAuthorization = false
        
        let favouriteStoryboard = UIStoryboard(name: "Favourite", bundle: nil)
        guard let favouriteCtrl = favouriteStoryboard.instantiateViewController(withIdentifier: "FavouriteViewCtrl") as? FavouriteViewController else {
            return
        }
        let favouriteNavigationController = RotationAwareNavigationController(rootViewController: favouriteCtrl)
        
        let timelineStoryboard = UIStoryboard(name: "TimelineView", bundle: nil)
        guard let timelineCtrl = timelineStoryboard.instantiateViewController(withIdentifier: "timelineViewCtrl") as? TimelineViewController else {
            return
        }
        let timelineNavigationController = RotationAwareNavigationController(rootViewController: timelineCtrl)
        
        var mapBarItem = UITabBarItem(title: "", image: UIImage(named: "mapIconUnselected")?.withRenderingMode(.alwaysOriginal),
                                      selectedImage: UIImage(named: "mapIcon")?.withRenderingMode(.alwaysOriginal))
        mapBarItem = mapBarItem.tabBarItemShowingOnlyImage()
        
        var favouriteBarItem = UITabBarItem(title: "", image: UIImage(named: "favouriteIconUnselected")?.withRenderingMode(.alwaysOriginal),
                                            selectedImage: UIImage(named: "favouriteIcon")?.withRenderingMode(.alwaysOriginal))
        favouriteBarItem = favouriteBarItem.tabBarItemShowingOnlyImage()
        
        var timelineBarItem = UITabBarItem(title: "", image: UIImage(named: "timelineIconUnselected")?.withRenderingMode(.alwaysOriginal),
                                           selectedImage: UIImage(named: "timelineIcon")?.withRenderingMode(.alwaysOriginal))
        timelineBarItem = timelineBarItem.tabBarItemShowingOnlyImage()
        
        mapNavigationController.tabBarItem = mapBarItem
        favouriteNavigationController.tabBarItem = favouriteBarItem
        timelineNavigationController.tabBarItem = timelineBarItem
        let tabBar = CustomTabBarViewController()
        tabBar.viewControllers = [timelineNavigationController, favouriteNavigationController, mapNavigationController]
        
        tabBar.selectedIndex = 1
        
        window.rootViewController = setUpDrawerController(navigationController: tabBar)
    }

    func setUpDrawerController(navigationController: UIViewController) -> DrawerController {
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
    
    func moveToRecommendationsController(navCtrl: UINavigationController) {
        let recommendationsStoryboard = UIStoryboard(name: "Recommendations", bundle: nil) 
        guard let recommendationsNavController = recommendationsStoryboard.instantiateInitialViewController() as? UINavigationController else {
            return
        }
        guard let recommendationsController = recommendationsNavController.topMostViewController as? RecommendationsViewController else {
            return
        }
        let noRecommendationsText = "No recommendations yet\n\nAfter you start applying to companies, we will recommend other great companies you may like\n\nGet cracking today!"
        recommendationsController.emptyRecomendationsListText = noRecommendationsText
        navCtrl.present(recommendationsNavController, animated: true, completion: nil)
    }

    func moveToContentViewController(navCtrl: UINavigationController, contentType: ContentType) {
        let contentStoryboard = UIStoryboard(name: "Content", bundle: nil)
        guard let contentViewController = contentStoryboard.instantiateViewController(withIdentifier: "ContentViewCtrl") as? ContentViewController else {
            return
        }
        contentViewController.contentType = contentType
        let navigationCtrl = RotationAwareNavigationController(rootViewController: contentViewController)

        navCtrl.present(navigationCtrl, animated: true, completion: nil)
    }

    func moveToContentViewController(navCtrl: UINavigationController, contentType: ContentType, url: String) {
        let contentStoryboard = UIStoryboard(name: "Content", bundle: nil)
        guard let contentViewController = contentStoryboard.instantiateViewController(withIdentifier: "ContentViewCtrl") as? ContentViewController else {
            return
        }
        contentViewController.contentType = contentType
        contentViewController.url = url
        let navigationCtrl = RotationAwareNavigationController(rootViewController: contentViewController)

        navCtrl.present(navigationCtrl, animated: true, completion: nil)
    }

    func moveToEditCoverLetter(_ navCtrl: UINavigationController, currentTemplate: TemplateEntity) {
        let coverLetterStoryboard = UIStoryboard(name: "EditCoverLetter", bundle: nil)
        guard let ctrl = coverLetterStoryboard.instantiateViewController(withIdentifier: "EditCoverLetterCtrl") as? EditCoverLetterViewController else {
            return
        }
        ctrl.currentTemplate = currentTemplate
        navCtrl.pushViewController(ctrl, animated: true)
    }

    func moveToChooseAttributes(_ navController: UINavigationController, currentTemplate: TemplateEntity, attribute: ChooseAttributes) {
        let chooseAttributesStoryboard = UIStoryboard(name: "ChooseAttributes", bundle: nil)
        guard let ctrl = chooseAttributesStoryboard.instantiateViewController(withIdentifier: "ChooseAttributesCtrl") as? ChooseAttributesViewController else {
            return
        }
        ctrl.currentTemplate = currentTemplate
        ctrl.currentAttributeType = attribute
        navController.pushViewController(ctrl, animated: true)
    }

    func moveToProcessedMessages(_ navController: UINavigationController, currentCompany: Company) {
        let processedMessagesStoryboard = UIStoryboard(name: "ProcessedMessages", bundle: nil)
        guard let ctrl = processedMessagesStoryboard.instantiateViewController(withIdentifier: "ProcessedMessagesCtrl") as? ProcessedMessagesViewController else {
            return
        }
        ctrl.currentCompany = currentCompany
        navController.pushViewController(ctrl, animated: true)
    }

    func showCompanyDetailsPopover(parentCtrl: UIViewController, company: Company) {
        guard let popOverVC = UIStoryboard(name: "CompanyDetails", bundle: nil).instantiateViewController(withIdentifier: "CompanyDetailsCtrl") as? CompanyDetailsViewController else {
            return
        }
        popOverVC.company = company
        let popOverVCWithNavCtrl = RotationAwareNavigationController(rootViewController: popOverVC)

        parentCtrl.present(popOverVCWithNavCtrl, animated: true, completion: nil)
    }

    func showNotificationPopover(parentCtrl: UIViewController, currentCompany: Company) {
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

    func showSuccessExtraInfoPopover(parentCtrl: UIViewController) {
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
    
    func moveToEmailVerification(navigCtrl: UINavigationController, company: Company) {
        let emailStoryboard = UIStoryboard(name: "F4SEmailVerification", bundle: nil)
        guard let emailController = emailStoryboard.instantiateViewController(withIdentifier: "EmailVerification") as? F4SEmailVerificationViewController else {
            return
        }
        emailController.emailWasVerified = { [weak self] in
            self?.moveToExtraInfoViewController(navigCtrl: navigCtrl, company: company)
        }
        navigCtrl.pushViewController(emailController, animated: true)
    }

    func moveToExtraInfoViewController(navigCtrl: UINavigationController, company: Company) {
        let extraInfoStoryboard = UIStoryboard(name: "ExtraInfo", bundle: nil)
        guard let extraInfoCtrl = extraInfoStoryboard.instantiateViewController(withIdentifier: "ExtraInfoCtrl") as? ExtraInfoViewController else {
            return
        }
        extraInfoCtrl.currentCompany = company
        navigCtrl.pushViewController(extraInfoCtrl, animated: true)
    }

    func moveToMessageController(parentCtrl: UIViewController, threadUuid: String, company: Company, placements: [TimelinePlacement], companies: [Company]) {
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

    func showRatePlacementPopover(parentCtrl: UIViewController, placementUuid: String, ratePlacementProtocol: CustomTabBarViewController? = nil) {
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
    
    func showFavouriteMaximumPopover(parentCtrl: UIViewController) {
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
