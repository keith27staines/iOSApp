//
//  UIFont+Extensions.swift
//  WorkfinderCommon
//
//  Created by Keith Dev on 25/03/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation

public extension UIFont {
    class func f4sSystemFont(size: CGFloat, weight: UIFont.Weight) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight:weight)
    }
}
