//
//  UIView+Extensions.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 27/08/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit
import WorkfinderCommon

private var skins: Skins = Skin.loadSkins()

public var globalSkin: Skin? = { return skins["workfinder"] }()

public extension UIView {
    var skin: Skin? { return globalSkin }
}

public extension UIView {
    func snapshotToImage() -> UIImage {
        UIGraphicsBeginImageContext(bounds.size)
        guard let context = UIGraphicsGetCurrentContext() else { return UIImage() }
        layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }
}
