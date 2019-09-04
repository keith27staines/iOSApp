//
//  UIColor+Extensions.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 16/08/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation

// MARK:- lighten and darken, saturated and desaturate
public extension UIColor {

    /// Returns a color lighter than the current instance by the specified percentage
    /// or by 30% if the percentage isn't specified
    ///
    /// - parameter percentage: The percentage by which the color is to be lightened (default = 30)
    /// - returns: The lighter color
    func lighter(by percentage: CGFloat = 30.0) -> UIColor {
        return self.adjustBrightness(by: abs(percentage))
    }
    
    /// Returns a color darker than the current instance by the specified percentage
    /// or by 30% if the percentage isn't specified
    ///
    /// - parameter percentage: The percentage by which the color is to be darkened (default = 30)
    /// - returns: The darker color
    func darker(by percentage: CGFloat = 30.0) -> UIColor {
        return self.adjustBrightness(by: -abs(percentage))
    }
    
    /// Returns a color more saturated than the current instance by the specified percentage
    /// or by 30% if the percentage isn't specified
    ///
    /// - parameter percentage: The percentage by which the color is to be saturated (default = 30)
    /// - returns: The more saturated color
    func saturated(by percentage: CGFloat = 30.0) -> UIColor {
        return self.adjustSaturation(by: abs(percentage))
    }
    
    /// Returns a color less saturated than the current instance by the specified percentage
    /// or by 30% if the percentage isn't specified
    ///
    /// - parameter percentage: The percentage by which the color is to be desaturated (default = 30)
    /// - returns: The desaturated color
    func desaturated(by percentage: CGFloat = 30.0) -> UIColor {
        return self.adjustSaturation(by: -abs(percentage))
    }
    
    func adjustBrightness(by percentage: CGFloat = 30.0) -> UIColor {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        if self.getHue(&h, saturation: &s, brightness: &b, alpha: &a) {
            if b < 1.0 {
                let newB: CGFloat
                if b == 0.0 {
                    newB = max(min(b + percentage/100, 1.0), 0.0)
                } else {
                    newB = max(min(b + (percentage/100.0)*b, 1.0), 0,0)
                }
                return UIColor(hue: h, saturation: s, brightness: newB, alpha: a)
            } else {
                let newS: CGFloat = min(max(s - (percentage/100.0)*s, 0.0), 1.0)
                return UIColor(hue: h, saturation: newS, brightness: b, alpha: a)
            }
        }
        return self
    }
    
    func adjustSaturation(by percentage: CGFloat = 30.0) -> UIColor {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        if self.getHue(&h, saturation: &s, brightness: &b, alpha: &a) {
            if s < 1.0 {
                let newS: CGFloat
                if s == 0.0 {
                    newS = max(min(s + percentage/100, 1.0), 0.0)
                } else {
                    newS = max(min(s + (percentage/100.0)*s, 1.0), 0,0)
                }
                return UIColor(hue: h, saturation: newS, brightness: b, alpha: a)
            } else {
                let newS: CGFloat = min(max(s - (percentage/100.0)*s, 0.0), 1.0)
                return UIColor(hue: h, saturation: newS, brightness: b, alpha: a)
            }
        }
        return self
    }
}

// MARK:- More initializers
public extension UIColor {
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
