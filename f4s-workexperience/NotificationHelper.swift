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
        F4SUserStatusService.shared.beginStatusUpdate()
        
        var title: String = ""
        var body: String = ""
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
        
        guard let type = extractNotificationType(userInfo: userInfo) else {
            return
        }
        
        if let threadId = userInfo["thread_uuid"] as? String {
            threadUuid = threadId
        }
        if let placementId = userInfo["placement_uuid"] as? String {
            placementUuid = placementId
        }
        
        if isAppActive {
            let alert = UIAlertController(title: title, message: body, preferredStyle: .alert)
            let show = UIAlertAction(title: NSLocalizedString("Show", comment: ""), style: .default) { [weak self] _ in
                self?.dispatchToBestDestination(for: type, threadUuid: threadUuid, placementUuid: placementUuid)
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
        } else {
            dispatchToBestDestination(for: type, threadUuid: threadUuid, placementUuid: placementUuid)
        }

    }
    
    func dispatchToBestDestination(for type: NotificationType, threadUuid: F4SUUID?, placementUuid: F4SUUID?) {
        switch type
        {
        case NotificationType.message:
            CustomNavigationHelper.sharedInstance.navigateToTimeline(threadUuid: threadUuid)
            
        case NotificationType.rating:
            if let topViewCtrl = CustomNavigationHelper.sharedInstance.topMostViewController() {
                CustomNavigationHelper.sharedInstance.presentRatePlacementPopover(parentCtrl: topViewCtrl, placementUuid: placementUuid!)
            }
        case NotificationType.recommendation:
            CustomNavigationHelper.sharedInstance.rewindAndNavigateToRecommendations(from: nil, show: nil)
        }
    }
    
    func extractNotificationType(userInfo:[AnyHashable: Any]) -> NotificationType? {
        guard let typeString = userInfo["type"] as? String else { return nil }
        switch typeString
        {
        case NotificationType.message.rawValue:
            return NotificationType.message
        case NotificationType.rating.rawValue:
            return NotificationType.rating
        case NotificationType.recommendation.rawValue:
            return NotificationType.recommendation
        default:
            assert(false, "Unexpected or missing type string: \(typeString)")
            return nil
        }
    }
}
