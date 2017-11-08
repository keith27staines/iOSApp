//
//  Style.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 30/10/2017.
//  Copyright © 2017 Founders4Schools. All rights reserved.
//

import Foundation

public struct Styler {

    static func styleAsScreenBackground(_ view: UIView, styling: F4SStyling) {
        view.backgroundColor = styling.colorScheme.screenBackground
    }
    static func styleAsStandardButton(_ button: UIButton, styling: F4SStyling) {
        button.setBackgroundColor(color: styling.colorScheme.standardControlEnabledBackground, forUIControlState: .normal)
        button.setBackgroundColor(color: styling.colorScheme.standardControlDisabledBackground, forUIControlState: .disabled)
        button.setTitleColor(styling.colorScheme.standardControlEnabledText, for: .normal)
        button.setTitleColor(styling.colorScheme.standardControlDisabledText, for: .disabled)
        button.titleEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        
    }
}

public enum F4SStyleName {
    case f4sStandard
    
    var styling: F4SStyling {
        switch self {
        default:
            return F4SStyling()
        }
    }
}

//let backgroundColor: UIColor = cerulean
//let enabledButtonBackground = ecstasy
//let disabledButtonBackground = seagull
//let enabledButtonTextColor = UIColor.white
//let disabledButtonTextColor = sail
//
//self.view.backgroundColor = backgroundColor
//self.doneButton.setBackgroundColor(color: enabledButtonBackground, forUIControlState: .normal)
//self.doneButton.setBackgroundColor(color: disabledButtonBackground, forUIControlState: .disabled)
//self.doneButton.setTitleColor(enabledButtonTextColor, for: .normal)
//self.doneButton.setTitleColor(disabledButtonTextColor, for: .disabled)

public struct F4SStyling {
    // MARK:- Color scheme - colors defined by purpose
    var colorScheme: ColorScheme = ColorScheme()
    public struct ColorScheme {
        var screenBackground: UIColor = F4SColorPalatte.cerulean
        var textOnScreenBackground: UIColor = F4SColorPalatte.white
        var standardControlEnabledBackground: UIColor = F4SColorPalatte.ecstasy
        var standardControlDisabledBackground: UIColor = F4SColorPalatte.seagull
        var standardControlEnabledText: UIColor = F4SColorPalatte.white
        var standardControlDisabledText: UIColor = F4SColorPalatte.sail
    }
    
    // MARK:- Typography - fonts defined by purpose
    public var typography: Typography = Typography()
    public struct Typography {
        /// title1 is bold, 28 point at standard size
        var title1 = UIFont.preferredFont(forTextStyle: .title1)
        /// title2 is 22 point at standard size
        var title2 = UIFont.preferredFont(forTextStyle: .title2)
        /// title3 is 20 point at standard size
        var title3 = UIFont.preferredFont(forTextStyle: .title3)
        /// headline is bold, 17 point at standard size
        var headline = UIFont.preferredFont(forTextStyle: .headline)
        /// body is 17 point at standard size
        var body = UIFont.preferredFont(forTextStyle: .body)
        /// callout is 16 point at standard size
        var callout = UIFont.preferredFont(forTextStyle: .callout)
        /// subHead is 15 point at standard size
        var subHead = UIFont.preferredFont(forTextStyle: .subheadline)
        /// footnote is 13 point at standard size
        var footnote = UIFont.preferredFont(forTextStyle: .footnote)
        /// caption1 is 12 point at standard size
        var caption1 = UIFont.preferredFont(forTextStyle: .caption1)
        /// caption2 is 11 point at standard size
        var caption2 = UIFont.preferredFont(forTextStyle: .caption2)
        /// Returns a font with monospaced digits useful for vertically aligning numbers
        func monospacedDigitFont(ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont {
            return UIFont.monospacedDigitSystemFont(ofSize: size, weight: weight)
        }
    }

    // MARK:- Artwork (Branding logos, etc defined by purpose)
    public var artwork: Artwork = Artwork()
    public struct Artwork {
        /// Use this wherever the plain workfinder logo is required
        var plainWorkfinderLogo = UIImage(named: "logo")!
        /// Use this wherever the text-decorated version of the workfinder logo is required
        var workfinderLogoWithText = UIImage(named: "logo2")!
        /// The branding logo for the partner
        var partnerIcon: UIImage? = nil
    }
}

// MARK: - Color palette
/// Colors defined in the color palette should not be referenced directly in the application (hence this enum is marked fileprivate). Instead, the app should reference colors by purpose, as defined in F4SStyling.ColorScheme
fileprivate struct F4SColorPalatte {
    public static let white = UIColor.white
    public static let black = UIColor.black
    public static let lightGray = UIColor.lightGray
    public static let darkGray = UIColor.darkGray
    public static let gray = UIColor.gray
    public static let cerulean = UIColor.init(red: 0.0/255.0, green: 160.0/255.0, blue: 220.0/255.0, alpha: 1.0)
    public static let regalBlue = UIColor.init(red: 0.0/255.0, green: 68.0/255.0, blue: 113.0/255.0, alpha: 1.0)
    public static let ecstasy = UIColor.init(red: 244.0/255.0, green: 123.0/255.0, blue: 22.0/255.0, alpha: 1.0)
    public static let peach = UIColor.init(red: 255.0/255.0, green: 231.0/255.0, blue: 187.0/255.0, alpha: 1.0)
    public static let seagull = UIColor.init(red: 104.0/255.0, green: 199.0/255.0, blue: 236.0/255.0, alpha: 1.0)
    public static let sail = UIColor.init(red: 207.0/255.0, green: 237.0/255.0, blue: 251.0/255.0, alpha: 1.0)
}




