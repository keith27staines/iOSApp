//
//  UILabel+WFComponents.swift
//  WorkfinderUI
//
//  Created by Keith on 08/09/2021.
//  Copyright © 2021 Workfinder. All rights reserved.
//

import UIKit

public extension UILabel {
    func applyStyle(_ style: WFTextStyle) {
        textColor = style.color
        font = style.font
    }
}
