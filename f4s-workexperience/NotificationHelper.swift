//
//  NotificationHelper.swift
//  f4s-workexperience
//
//  Created by Timea Tivadar on 1/12/17.
//  Copyright © 2017 freshbyte. All rights reserved.
//

import Foundation
class NotificationHelper {
    class var sharedInstance: NotificationHelper {
        struct Static {
            static let instance: NotificationHelper = NotificationHelper()
        }
        return Static.instance
    }

    func handleRemoteNotification(userInfo: [AnyHashable: Any], window: UIWindow, isAppActive: Bool) {
        log.debug(userInfo)
        UIApplication.shared.applicationIconBadgeNumber = UIApplication.shared.applicationIconBadgeNumber - 1

        var title: String = ""
        var body: String = ""
        var type: NotificationType = NotificationType.message
        var threadUuid: String = ""
        var placementUuid: String = ""

        if let aps = userInfo["aps"] as? [AnyHashable: Any] {
            if let alert = aps["alert"] as? [AnyHashable: Any] {
                if let t = alert["title"] as? String {
                    title = t
                }
                if let b = alert["body"] as? String {
                    body = b
                }
            }
        }
        if let t = userInfo["type"] as? String {
            switch t
            {
            case NotificationType.message.rawValue:
                type = NotificationType.message
                break
            case NotificationType.rating.rawValue:
                type = NotificationType.rating
                break
            default:
                type = NotificationType.message
                break
            }
        }
        if let threadId = userInfo["thread_uuid"] as? String {
            threadUuid = threadId
        }
        if let placementId = userInfo["placement_uuid"] as? String {
            placementUuid = placementId
        }

        switch type
        {
        case NotificationType.message:
            if !isAppActive {
                // need to move to message screen
                CustomNavigationHelper.sharedInstance.createTabBarControllersAndMoveToTimeline(window: window, threadUuid: threadUuid)
            } else {
                if let topViewCtrl = window.rootViewController?.topMostViewController {
                    if let sideMenuViewCtrl = topViewCtrl as? SideMenuViewController {
                        if let centerCtrl = sideMenuViewCtrl.evo_drawerController?.centerViewController as? CustomTabBarViewController {
                            if let currentTabCtrl = centerCtrl.selectedViewController as? TimelineViewController {
                                // go to message screen
                                currentTabCtrl.threadUuid = threadUuid
                                currentTabCtrl.goToMessageViewCtrl()
                                return
                            }
                            if let currentTabCtrl = centerCtrl.selectedViewController as? UINavigationController {
                                if let timelineCtrl = currentTabCtrl.topMostViewController as? TimelineViewController {
                                    // go to message screen
                                    timelineCtrl.threadUuid = threadUuid
                                    timelineCtrl.goToMessageViewCtrl()
                                    return
                                }
                            }
                        }
                    }
                }
                let alert = UIAlertController(title: title, message: body, preferredStyle: .alert)
                let show = UIAlertAction(title: NSLocalizedString("Show", comment: ""), style: .default) { _ in
                    log.debug("user received notif and pressed show")
                    if let topViewCtrl = window.rootViewController as? DrawerController {
                        if let centerCtrl = topViewCtrl.centerViewController as? CustomTabBarViewController {
                            if let currentTabCtrl = centerCtrl.selectedViewController as? MessageContainerViewController {
                                // go to message screen
                                currentTabCtrl.showMessageWithThread(threadUuid: threadUuid)
                                return
                            }
                            if let currentTabCtrl = centerCtrl.selectedViewController as? UINavigationController {
                                if let messageCtrl = currentTabCtrl.topMostViewController as? MessageContainerViewController {
                                    // go to message screen
                                    messageCtrl.showMessageWithThread(threadUuid: threadUuid)
                                    return
                                }
                            }
                        }
                    }
                    CustomNavigationHelper.sharedInstance.createTabBarControllersAndMoveToTimeline(window: window, threadUuid: threadUuid)
                }
                let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default) { _ in
                    log.debug("user received notif and pressed cancel")
                }
                alert.addAction(show)
                alert.addAction(cancel)
                if let window = UIApplication.shared.delegate?.window {
                    if let rootViewCtrl = window?.rootViewController {
                        if let topViewController = rootViewCtrl.topMostViewController {
                            topViewController.present(alert, animated: true) {}
                        } else {
                            rootViewCtrl.present(alert, animated: true) {}
                        }
                    }
                }
            }
            break
        case NotificationType.rating:
            // show rating popover
            if let topViewCtrl = window.rootViewController?.topMostViewController {
                if let drawerCtrl = topViewCtrl as? DrawerController {
                    if let centerCtrl = drawerCtrl.centerViewController {
                        CustomNavigationHelper.sharedInstance.presentRatePlacementPopover(parentCtrl: centerCtrl, placementUuid: placementUuid)
                    }
                } else if let sideMenuViewCtrl = topViewCtrl as? SideMenuViewController {
                    if let centerCtrl = sideMenuViewCtrl.evo_drawerController?.centerViewController as? CustomTabBarViewController {
                        if let currentTabCtrl = centerCtrl.selectedViewController {
                            CustomNavigationHelper.sharedInstance.presentRatePlacementPopover(parentCtrl: currentTabCtrl, placementUuid: placementUuid)
                        }
                    }
                } else {
                    CustomNavigationHelper.sharedInstance.presentRatePlacementPopover(parentCtrl: topViewCtrl, placementUuid: placementUuid)
                }
            }
            break
        }
    }

    func handleNotificationAtLaunch(userInfo: [AnyHashable: Any], window: UIWindow) {
        UIApplication.shared.applicationIconBadgeNumber = UIApplication.shared.applicationIconBadgeNumber - 1
        var type: NotificationType = NotificationType.message
        var threadUuid: String = ""
        var placementUuid: String = ""
        if let t = userInfo["type"] as? String {
            switch t
            {
            case NotificationType.message.rawValue:
                type = NotificationType.message
                break
            case NotificationType.rating.rawValue:
                type = NotificationType.rating
                break
            default:
                type = NotificationType.message
                break
            }
        }
        if let threadId = userInfo["thread_uuid"] as? String {
            threadUuid = threadId
        }
        if let placementId = userInfo["placement_uuid"] as? String {
            placementUuid = placementId
        }
        switch type
        {
        case NotificationType.message:
            CustomNavigationHelper.sharedInstance.createTabBarControllersAndMoveToTimeline(window: window, threadUuid: threadUuid)
            break
        case NotificationType.rating:
            CustomNavigationHelper.sharedInstance.createTabBarControllers(window: window)
            if let viewCtrl = window.rootViewController?.topMostViewController {
                CustomNavigationHelper.sharedInstance.presentRatePlacementPopover(parentCtrl: viewCtrl, placementUuid: placementUuid)
            }
            break
        }
    }

    func updateToolbarButton(window: UIWindow) {
        if let topViewCtrl = window.rootViewController as? DrawerController {
            if let centerCtrl = topViewCtrl.centerViewController as? CustomTabBarViewController {
                centerCtrl.checkForUnreadMessages()
            }
        }
    }
}
