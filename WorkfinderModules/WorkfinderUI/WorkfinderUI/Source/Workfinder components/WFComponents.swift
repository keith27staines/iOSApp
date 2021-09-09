//
//  WFControls.swift
//  WorkfinderUI
//
//  Created by Keith on 08/09/2021.
//  Copyright © 2021 Workfinder. All rights reserved.
//

import UIKit

public struct WFComponentsFactory {
    
    static private let defaultBorderWidth: CGFloat = 1
    static private let defaultBackgroundColor = WFColorPalette.white
    static private let defaultBorderColor = WFColorPalette.gray4
    static private let defaultTextColor = WFColorPalette.gray4
    
    static public func makeSmallTag() -> WFTextCapsule {
        makeTextCapsule(heightClass: .small)
    }
    
    static public func makeTextCapsule(
        heightClass: WFComponentsHeightClass,
        textColor: UIColor? = nil,
        backgroundColor: UIColor? = nil,
        borderColor: UIColor? = nil
    ) -> WFTextCapsule {
        let fontSize = heightClass.fontSize
        let font = WFTextStyle.standardFont(size: fontSize, weight: .regular)
        let textStyle = WFTextStyle(font: font, color: textColor ?? defaultTextColor)
        return WFTextCapsule(
            heightClass: heightClass,
            borderWidth: defaultBorderWidth,
            borderColor: borderColor ?? defaultBorderColor,
            backgroundColor: backgroundColor ?? defaultBackgroundColor,
            textStyle: textStyle
        )
    }
    
}

fileprivate extension WFComponentsHeightClass {
    var fontSize: CGFloat {
        switch self {
        case .small: return 12
        case .larger: return 14
        case .clickable: return 16
        }
    }
}

