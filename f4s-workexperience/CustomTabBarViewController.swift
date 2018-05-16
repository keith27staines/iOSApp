//
//  CustomTabBarViewController.swift
//  f4s-workexperience
//
//  Created by Sergiu Simon on 15/11/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import UIKit
import Reachability

class CustomTabBarViewController: UITabBarController {

    var reachability: Reachability?
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBar()
        setupReachability(nil, useClosures: true)
        startNotifier()
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(catchUserStatusUpdatedNotification),
                                       name: .f4sUserStatusUpdated,
                                       object: nil)
        if let status = F4SUserStatusService.shared.userStatus {
            processUserStatusUpdate(status)
        }
    }
    
    @objc func catchUserStatusUpdatedNotification(notification: Notification) {
        guard let status = notification.object as? F4SUserStatus else {
            return
        }
        processUserStatusUpdate(status)
    }
    
    func processUserStatusUpdate(_ status: F4SUserStatus) {
        setTimelineTabBarImageFrom(status: status)
        displayRatingPopover(unratedPlacements: status.unratedPlacements)
    }
    
    func setTimelineTabBarImageFrom(status: F4SUserStatus) {
        guard let timelineNavViewCtrl = self.viewControllers?.first as? RotationAwareNavigationController else { return }
        let unselectedName = status.unreadMessageCount == 0 ? "timelineIconUnselected" : "timelineIconUnreadUnselected"
        let selectedName = status.unreadMessageCount == 0 ? "timelineIcon" : "timelineIconUnread"
        DispatchQueue.main.async {
            timelineNavViewCtrl.tabBarItem.image = UIImage(named: unselectedName)?.withRenderingMode(.alwaysOriginal)
            timelineNavViewCtrl.tabBarItem.selectedImage = UIImage(named: selectedName)?.withRenderingMode(.alwaysOriginal)
            UserDefaults.standard.set(true, forKey: UserDefaultsKeys.shouldLoadTimeline)
        }
    }
    
    func displayRatingPopover(unratedPlacements: [F4SUUID]) {
        guard let placementUuid = unratedPlacements.first, let topViewCtrl = self.topMostViewController else { return }

        if topViewCtrl is TimelineViewController || topViewCtrl is MessageViewController || topViewCtrl is MessageContainerViewController || topViewCtrl is MapViewController {
            if let centerCtrl = self.evo_drawerController?.centerViewController as? CustomTabBarViewController {
                if let currentTabCtrl = centerCtrl.selectedViewController {
                    CustomNavigationHelper.sharedInstance.presentRatePlacementPopover(parentCtrl: currentTabCtrl, placementUuid: placementUuid, ratePlacementProtocol: self)
                }
            }
        } else {
            CustomNavigationHelper.sharedInstance.presentRatePlacementPopover(parentCtrl: topViewCtrl, placementUuid: placementUuid, ratePlacementProtocol: self)
        }
    }

    deinit {
        stopNotifier()
        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - UI Setup
    fileprivate func configureTabBar() {
        

        self.tabBar.isTranslucent = false
        self.tabBar.backgroundColor = UIColor.white
        switch Config.environment {
        case .staging:
            self.tabBar.barTintColor = WorkfinderColor.stagingGold
            self.tabBar.tintColor = UIColor(red: 125 / 255, green: 125 / 255, blue: 125 / 255, alpha: 1)
        case .production:
            self.tabBar.barTintColor = UIColor(netHex: Colors.azure)
            self.tabBar.tintColor = UIColor(red: 108 / 255, green: 181 / 255, blue: 246 / 255, alpha: 1)
        }

    }

    override func viewWillAppear(_ animation: Bool) {
        super.viewWillAppear(animation)
        addMenuCustomGesture()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeMenuCustomGesture()
    }
}

// MARK: - menu actions
extension CustomTabBarViewController {
    func addMenuCustomGesture() {
        self.evo_drawerController?.gestureShouldRecognizeTouchBlock = menuGestureShouldRecognizeTouch
    }

    func removeMenuCustomGesture() {
        self.evo_drawerController?.gestureShouldRecognizeTouchBlock = nil
    }

    func menuGestureShouldRecognizeTouch(drawerController _: DrawerController, gestureRecognizer _: UIGestureRecognizer, touch _: UITouch) -> Bool {
        self.evo_drawerController?.openDrawerGestureModeMask = .all
        if self.evo_drawerController?.openSide == .none {
            return false
        }
        if self.selectedIndex == 2 { // MapViewController
            self.evo_drawerController?.openDrawerGestureModeMask = .custom
        }
        return false
    }
}

// MARK: - Reachability Setup
extension CustomTabBarViewController {

    func setupReachability(_: String?, useClosures _: Bool) {
        let reachability = Reachability()
        self.reachability = reachability

        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(_:)), name: Notification.Name.reachabilityChanged, object: reachability)
    }

    func startNotifier() {
        do {
            try reachability?.startNotifier()
        } catch {
            return
        }
    }

    func stopNotifier() {
        reachability?.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: Notification.Name.reachabilityChanged, object: nil)
        reachability = nil
    }

    @objc func reachabilityChanged(_ note: Notification) {
        guard let reachability = note.object as? Reachability else {
            return
        }
        if reachability.isReachableByAnyMeans {
            F4SUserStatusService.shared.beginStatusUpdate()
        }
    }
}

// MARK: - Api Calls

extension CustomTabBarViewController: RatePlacementProtocol {
    internal func dismissRateController() { }
}

protocol RatePlacementProtocol: class {
    func dismissRateController()
}


enum TabIndex : Int {
    case timeline = 0
    case favourites = 1
    case map = 2
}
extension CustomTabBarViewController {
    
    static func rewindToDrawerAndPresentRecommendations(vc: UIViewController) {
        recursiveRewindToDrawer(from: vc) { (drawerController) in
            guard let centerController = drawerController?.centerViewController else { return }
            guard let tabBarCtrl = centerController as? CustomTabBarViewController else { return }
            let recommendationsStoryboard = UIStoryboard(name: "Recommendations", bundle: nil)
            guard let recommendationsNavController = recommendationsStoryboard.instantiateInitialViewController() else {
                return
            }
            guard let recommendationsController = recommendationsNavController.topMostViewController as? RecommendationsViewController else {
                return
            }
            let noRecommendationsText = "No recommendations yet\n\nWe have no companies to recommend based on your recent application(s).  The more you apply, the more great companies we can recommend to you.\n\nKeep going, the world's your oyster!"
            recommendationsController.emptyRecomendationsListText = noRecommendationsText
            tabBarCtrl.selectedIndex = 0
            tabBarCtrl.selectedViewController?.present(recommendationsNavController, animated: true, completion: nil)
        }
    }
    
    static func rewindToDrawerAndSelectTab(vc: UIViewController, tab: TabIndex) {
        recursiveRewindToDrawer(from: vc, completion: { drawerController in
            guard let centerController = drawerController?.centerViewController else { return }
            guard let tabBarCtrl = centerController as? CustomTabBarViewController else { return }
            tabBarCtrl.selectedIndex = tab.rawValue
        })
    }
    
    static func recursiveRewindToDrawer(from vc: UIViewController?, completion: @escaping (DrawerController?) -> Void) {
        guard let vc = vc else {
            completion(nil)
            return
        }
        if let drawerController = vc as? DrawerController {
            completion(drawerController)
            return
        }
        let presentingViewController = vc.presentingViewController
        vc.dismiss(animated: false, completion: {
            return recursiveRewindToDrawer(from: presentingViewController, completion: completion)
        })
    }
}
