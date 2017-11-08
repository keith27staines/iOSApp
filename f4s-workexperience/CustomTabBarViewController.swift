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

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBar()
        setupReachability(nil, useClosures: true)
        startNotifier()
    }

    deinit {
        stopNotifier()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - UI Setup
    fileprivate func configureTabBar() {
        self.tabBar.barTintColor = UIColor(netHex: Colors.azure)

        self.tabBar.isTranslucent = false
        self.tabBar.backgroundColor = UIColor.white
        self.tabBar.tintColor = UIColor(red: 108 / 255, green: 181 / 255, blue: 246 / 255, alpha: 1)
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
        print("--- start notifier")
        do {
            try reachability?.startNotifier()
        } catch {
            return
        }
    }

    func stopNotifier() {
        print("--- stop notifier")
        reachability?.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: Notification.Name.reachabilityChanged, object: nil)
        reachability = nil
    }

    @objc func reachabilityChanged(_ note: Notification) {
        guard let reachability = note.object as? Reachability else {
            return
        }
        if reachability.connection == .none {
            debugPrint("network not reachable")
        } else {
            debugPrint("network is reachable")
            self.checkForUnreadMessages()
        }
    }
}

// MARK: - Api Calls
extension CustomTabBarViewController {

    func checkForUnreadMessages() {
        UserService.sharedInstance.getUnreadMessagesCount { _, result in
            switch result {
            case .value(let boxed):
                let unreadCount = boxed.value.unreadCount
                if unreadCount > 0 {
                    if let viewCtrls = self.viewControllers {
                        if let timelineNavViewCtrl = viewCtrls.first as? RotationAwareNavigationController {
                            DispatchQueue.main.async {
                                timelineNavViewCtrl.tabBarItem.image = UIImage(named: "timelineIconUnreadUnselected")?.withRenderingMode(.alwaysOriginal)
                                timelineNavViewCtrl.tabBarItem.selectedImage = UIImage(named: "timelineIconUnread")?.withRenderingMode(.alwaysOriginal)
                            }
                        }
                    }
                }
                if boxed.value.unratedPlacements.count > 0 {
                    // show rating popover
                    if let topViewCtrl = self.topMostViewController, let placementUuid = boxed.value.unratedPlacements.first {
                        if topViewCtrl is TimelineViewController || topViewCtrl is MessageViewController || topViewCtrl is MessageContainerViewController || topViewCtrl is MapViewController {
                            if let centerCtrl = self.evo_drawerController?.centerViewController as? CustomTabBarViewController {
                                if let currentTabCtrl = centerCtrl.selectedViewController {
                                    CustomNavigationHelper.sharedInstance.showRatePlacementPopover(parentCtrl: currentTabCtrl, placementUuid: placementUuid, ratePlacementProtocol: self)
                                }
                            }
                        } else {
                            CustomNavigationHelper.sharedInstance.showRatePlacementPopover(parentCtrl: topViewCtrl, placementUuid: placementUuid, ratePlacementProtocol: self)
                        }
                    }
                }
                break
            case .error(let err):
                debugPrint(err)
                break
            case .deffinedError(let err):
                debugPrint(err)
                break
            }
        }
    }
}

extension CustomTabBarViewController: RatePlacementProtocol {
    internal func dismissRateController() {
        checkForUnreadMessages()
    }
}

protocol RatePlacementProtocol: class {
    func dismissRateController()
}
