//
//  Style.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 30/10/2017.
//  Copyright © 2017 Founders4Schools. All rights reserved.
//

import Foundation

public enum F4SButtonStyle {
    case primary
    case secondary
    case minor
}

public enum F4SPageStyles {
    case standardPageBackground
}

public struct F4SBackgroundViewStyler {
    public static func apply(style: F4SPageStyles, backgroundView: UIView) {
        switch style {
        case .standardPageBackground:
            backgroundView.backgroundColor = RGBA.workfinderGreen.uiColor
        }
    }
}

//public struct WorkfinderColor {
//    public static let green = UIColor(red: 167, green: 222, blue: 54)
//    public static let purple = UIColor(red: 72, green: 38, blue: 127)
//    public static let purpleDisabled = UIColor(red: 141, green: 122, blue: 173)
//    public static let pink = UIColor(red:226, green:16, blue: 79)
//    public static let pinkDisabled = UIColor(red: 230, green: 95, blue:  136)
//    public static let stagingGold = UIColor(red: 255, green: 212, blue: 76)
//}

public struct F4SButtonStyler {
    public static func apply(style: F4SButtonStyle, button: UIButton) {
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 8
        
        switch style {
        case .primary:
            button.setBackgroundColor(color: RGBA.workfinderPurple.uiColor, forUIControlState: .normal)
            button.setTitleColor(UIColor.white, for: .normal)
            button.setTitleColor(UIColor.white, for: .disabled)
            button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title2)
        case .secondary:
            button.setBackgroundColor(color: RGBA.workfinderPink.uiColor, forUIControlState: .normal)
            button.setTitleColor(UIColor.white, for: .normal)
            button.setTitleColor(UIColor.white, for: .disabled)
            button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title2)
        case .minor:
            button.backgroundColor = UIColor.clear
            button.setTitleColor(UIColor.white, for: .normal)
            button.setTitleColor(UIColor.lightGray, for: .disabled)
            button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        }
    }
}



