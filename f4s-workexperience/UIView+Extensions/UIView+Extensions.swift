//
//  UIView+Extensions.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 27/08/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit

extension UIView {
    var skin: Skin? {
        get {
            return ((UIApplication.shared.delegate) as! AppDelegate).skin
        }
    }
}
