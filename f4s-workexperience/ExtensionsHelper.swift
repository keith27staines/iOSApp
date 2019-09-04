//
//  ExtensionsHelper.swift
//  f4s-workexperience
//
//  Created by Andreea Rusu on 26/04/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import UIKit
import Foundation

extension String {

    func isValidName() -> Bool {
        let regexSymbols: NSRegularExpression?
        do {
            regexSymbols = try NSRegularExpression(pattern: "[^ A-Za-z0-9_-]", options: [])
        } catch _ as NSError {
            regexSymbols = nil
        }
        if (regexSymbols?.numberOfMatches(in: self, options: [], range: NSMakeRange(0, self.count)))! > 0 {
            return false
        }
        return true
    }

    func isVoucherCode() -> Bool {
        let regexSymbols: NSRegularExpression?
        do {
            regexSymbols = try NSRegularExpression(pattern: "[^ A-Za-z0-9]", options: [])
        } catch _ as NSError {
            regexSymbols = nil
        }
        if (regexSymbols?.numberOfMatches(in: self, options: [], range: NSMakeRange(0, self.count)))! > 0 || self.contains(" ") {
            return false
        }
        return true
    }

    static func randomString(length: Int) -> String {

        let letters: NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)

        var randomString = ""

        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }

        return randomString
    }

}

extension UIView {
    static func gradient(view: UIView, colorTop: CGColor, colorBottom: CGColor) -> UIView {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame.size = view.frame.size

        view.layer.addSublayer(gradientLayer)
        return view
    }
}

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
