//
//  ExtensionsHelper.swift
//  f4s-workexperience
//
//  Created by Andreea Rusu on 26/04/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import UIKit
import Foundation

extension NSObject {
    /// Use an NSLocking object as a mutex for a critical section of code
    func synchronized<L: NSLocking>(lockable: L, criticalSection: () -> Void) {
        lockable.lock()
        criticalSection()
        lockable.unlock()
    }
}

public protocol ViewControllerContainer {

    var topMostViewController: UIViewController? { get }
}

extension UIViewController: ViewControllerContainer {

    @objc public var topMostViewController: UIViewController? {

        if let presentedView = presentedViewController {

            return recurseViewController(viewController: presentedView)
        }

        return children.last.map(recurseViewController)
    }
}

extension UITabBarController {

    public override var topMostViewController: UIViewController? {

        return selectedViewController.map(recurseViewController)
    }
}

extension UINavigationController {

    public override var topMostViewController: UIViewController? {

        return viewControllers.last.map(recurseViewController)
    }
}

extension UIWindow: ViewControllerContainer {

    public var topMostViewController: UIViewController? {

        return rootViewController.map(recurseViewController)
    }
}

func recurseViewController(viewController: UIViewController) -> UIViewController {

    return viewController.topMostViewController.map(recurseViewController) ?? viewController
}

extension Double {
    func round(nearest: Double = 0.5) -> Double {
        let n = 1 / nearest
        let numberToRound = self * n
        return numberToRound.rounded() / n
    }
}
