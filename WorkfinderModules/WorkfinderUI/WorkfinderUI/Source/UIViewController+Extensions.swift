//
//  UIViewController+Extensions.swift
//  WorkfinderCommon
//
//  Created by Keith Dev on 25/03/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import UIKit

fileprivate var skins: Skins = Skin.loadSkins()

public extension UIViewController {
    
    var skin: Skin? { return skins["workfinder"] }

    var splashColor: UIColor {
        return skin?.navigationBarSkin.barTintColor.uiColor ?? UIColor.white
    }
    
    /// Style the navigation bar
    func styleNavigationController() {
        Skinner().apply(navigationBarSkin: skin?.navigationBarSkin, to: self)
        setNeedsStatusBarAppearanceUpdate()
    }
}
