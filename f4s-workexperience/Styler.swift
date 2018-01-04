//
//  Styler.swift
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
            backgroundView.backgroundColor = UIColor(red: 179, green: 220, blue: 86)
        }
    }
}

public struct F4SButtonStyler {
    public static func apply(style: F4SButtonStyle, button: UIButton) {
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 10
        switch style {
        case .primary:
            button.setBackgroundColor(color: UIColor(red: 67, green: 40, blue: 122), forUIControlState: .normal)
            button.setTitleColor(UIColor.white, for: .normal)
            button.setBackgroundColor(color: UIColor(red: 122, green: 131, blue: 93), forUIControlState: .disabled)
            button.setTitleColor(UIColor.white, for: .disabled)
            button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title2)
        case .secondary:
            button.setBackgroundColor(color: UIColor(red: 207, green: 48, blue: 82), forUIControlState: .normal)
            button.setTitleColor(UIColor.white, for: .normal)
            button.setBackgroundColor(color: UIColor(red: 122, green: 131, blue: 93), forUIControlState: .disabled)
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
