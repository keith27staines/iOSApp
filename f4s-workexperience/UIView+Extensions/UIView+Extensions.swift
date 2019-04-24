//
//  UIView+Extensions.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 27/08/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit
import WorkfinderCommon

extension UIView {
    var skin: Skin? {
        get {
            return ((UIApplication.shared.delegate) as! AppDelegate).skin
        }
    }
}

extension UIView {
    func snapshotToImage() -> UIImage {
        UIGraphicsBeginImageContext(bounds.size)
        guard let context = UIGraphicsGetCurrentContext() else { return UIImage() }
        layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }
}
