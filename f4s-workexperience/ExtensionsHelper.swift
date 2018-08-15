//
//  ExtensionsHelper.swift
//  f4s-workexperience
//
//  Created by Andreea Rusu on 26/04/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import UIKit
import Foundation

// extension for hex colors
extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")

        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }

    convenience init(netHex: Int) {
        self.init(red: (netHex >> 16) & 0xFF, green: (netHex >> 8) & 0xFF, blue: netHex & 0xFF)
    }
}

extension String {

    func isEmail() -> Bool {
        let regexOptions: NSRegularExpression.Options? = NSRegularExpression.Options.caseInsensitive
        let regex: NSRegularExpression?
        do {
            regex = try NSRegularExpression(pattern: "^[\\w!#$%&'*+\\-/=?\\^_`{|}~]+(\\.[\\w!#$%&'*+\\-/=?\\^_`{|}~]+)*@((([\\w]+([\\-\\w])*\\.)+[a-zA-Z]{2,4})|(([0-9]{1,3}\\.){3}[0-9]{1,3}))$", options: regexOptions!)
        } catch _ as NSError {
            regex = nil
        }
        return regex?.firstMatch(in: self, options: [], range: NSMakeRange(0, self.count)) != nil
    }

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

    func sha1() -> String {
        let data = self.data(using: String.Encoding.utf8)!
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA1($0, CC_LONG(data.count), &digest)
        }
        let hexBytes = digest.map { String(format: "%02hhx", $0) }
        return hexBytes.joined()
    }

    func capitalizingFirstLetter() -> String {
        let first = String(prefix(1)).capitalized
        let other = String(dropFirst())
        return first + other
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }

    func index(of string: String, options: String.CompareOptions = .literal) -> String.Index? {
        return range(of: string, options: options, range: nil, locale: nil)?.lowerBound
    }

    func index(of string: String, options: String.CompareOptions = .literal) -> Int? {
        if let indexOf = range(of: string, options: options, range: nil, locale: nil)?.lowerBound {
            return self.distance(from: self.startIndex, to: indexOf)
        }
        return nil
    }

    func stringByReplacingFirstOccurrenceOfString(target: String, withString replaceString: String) -> String {
        if let range = self.range(of: target) {
            return self.replacingCharacters(in: range, with: replaceString)
        }
        return self
    }
}

extension Date {
    func isGreaterThanDate(dateToCompare: Date) -> Bool {
        // Declare Variables
        var isGreater = false

        // Compare Values
        if self.compare(dateToCompare as Date) == ComparisonResult.orderedDescending {
            isGreater = true
        }

        // Return Result
        return isGreater
    }

    func isLessThanDate(dateToCompare: Date) -> Bool {
        // Declare Variables
        var isLess = false

        // Compare Values
        if self.compare(dateToCompare as Date) == ComparisonResult.orderedAscending {
            isLess = true
        }

        // Return Result
        return isLess
    }

    func equalToDate(dateToCompare: Date) -> Bool {
        // Declare Variables
        var isEqualTo = false

        // Compare Values
        if self.compare(dateToCompare as Date) == ComparisonResult.orderedSame {
            isEqualTo = true
        }

        // Return Result
        return isEqualTo
    }
}

extension Date {
    private struct DateFormatters {
        private static var _rfc3339UtcDateFormatter: DateFormatter?
        private static var _rfc3339UtcDateTimeFormatter: DateFormatter?
        private static var _rfc3339UtcDateTimeSubsecondFormatter: DateFormatter?

        static var rfc3339UtcDateFormatter: DateFormatter {
            if _rfc3339UtcDateFormatter == .none {
                _rfc3339UtcDateFormatter = DateFormatter()
                _rfc3339UtcDateFormatter?.locale = NSLocale(localeIdentifier: "en_GB") as Locale?
                _rfc3339UtcDateFormatter?.dateFormat = "yyyy'-'MM'-'dd"
                _rfc3339UtcDateFormatter?.timeZone = NSTimeZone(forSecondsFromGMT: 0) as TimeZone?
            }

            return _rfc3339UtcDateFormatter!
        }

        static var rfc3339UtcDateTimeFormatter: DateFormatter {
            if _rfc3339UtcDateTimeFormatter == .none {
                _rfc3339UtcDateTimeFormatter = DateFormatter()
                _rfc3339UtcDateTimeFormatter?.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale?
                _rfc3339UtcDateTimeFormatter?.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ssXXXXX"
                _rfc3339UtcDateTimeFormatter?.timeZone = NSTimeZone(forSecondsFromGMT: 0) as TimeZone?
            }

            return _rfc3339UtcDateTimeFormatter!
        }

        static var rfc3339UtcDateTimeSubsecondFormatter: DateFormatter {
            if _rfc3339UtcDateTimeSubsecondFormatter == .none {
                _rfc3339UtcDateTimeSubsecondFormatter = DateFormatter()
                _rfc3339UtcDateTimeSubsecondFormatter?.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale?
                _rfc3339UtcDateTimeSubsecondFormatter?.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSSSSXXXXX"
                _rfc3339UtcDateTimeSubsecondFormatter?.timeZone = NSTimeZone(forSecondsFromGMT: 0) as TimeZone?
            }

            return _rfc3339UtcDateTimeSubsecondFormatter!
        }
    }

    /**
     Date part formatted for posting JSON data to the REST API.

     This value should not be used for formatting dates to be displayed in the user interface.
     */
    var rfc3339UtcDate: String { return DateFormatters.rfc3339UtcDateFormatter.string(from: self) }

    /**
     Date and time formatted for posting JSON data to the REST API.

     This value should not be used for formatting dates to be displayed in the user interface.
     */
    var rfc3339UtcDateTime: String { return DateFormatters.rfc3339UtcDateTimeFormatter.string(from: self) }

    /**
     Attempts to parse a date time expecting something like 2016-10-19T13:45:23.000Z.

     This function is intended for parsing dates received from the REST API.

     - parameter string: Input string to parse into a NSDate
     - returns: Date if the string could be successfully parsed, nil otherwise.
     */
    static func dateFromRfc3339(string: String) -> Date? {
        if let date = DateFormatters.rfc3339UtcDateTimeFormatter.date(from: string) {
            return date
        } else {
            return DateFormatters.rfc3339UtcDateTimeSubsecondFormatter.date(from: string)
        }
    }

    func dateToStringRfc3339() -> String? {
        let dateString = DateFormatters.rfc3339UtcDateTimeFormatter.string(from: self)
        if !dateString.isEmpty {
            return dateString
        } else {
            return DateFormatters.rfc3339UtcDateTimeSubsecondFormatter.string(from: self)
        }
    }
}

extension UIFont {
    class func f4sSystemFont(size: CGFloat, weight: UIFont.Weight) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight:weight)
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

extension UIButton {
    private func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()

        context!.setFillColor(color.cgColor)
        context!.fill(rect)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image!
    }

    func setBackgroundColor(color: UIColor, forUIControlState state: UIControlState) {
        self.setBackgroundImage(imageWithColor(color: color), for: state)
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

        return childViewControllers.last.map(recurseViewController)
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
