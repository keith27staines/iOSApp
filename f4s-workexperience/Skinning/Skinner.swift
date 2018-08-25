//
//  Skinner.swift
//  Skins
//
//  Created by Keith Dev on 13/08/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit

public protocol Skinning  {
    func apply(buttonSkin: ButtonSkin?, to button: UIButton)
    func apply(navigationBarSkin: NavigationBarSkin?, to controller: UIViewController)
    func apply(tabBarSkin: TabBarSkin?, to controller: UITabBarController)
}

public struct Skinner : Skinning {
    
    public func apply(navigationBarSkin: NavigationBarSkin?, to controller: UIViewController) {
        guard let navigationBar =  controller.navigationController?.navigationBar else {
            return
        }
        navigationBar.isHidden = false
        guard let skin = navigationBarSkin else {
            navigationBar.isTranslucent = false
            navigationBar.barTintColor = RGBA.white.uiColor
            navigationBar.tintColor = RGBA.black.uiColor
            navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:RGBA.black.uiColor]
            let image = UIImage()
            navigationBar.setBackgroundImage(image, for: .default)
            navigationBar.shadowImage = image
            return
        }
        
        navigationBar.isTranslucent = false
        navigationBar.barTintColor = skin.barTintColor.uiColor
        navigationBar.tintColor = skin.itemTintColor.uiColor
        navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:skin.titleTintColor.uiColor]
        if skin.hasDropShadow {
            navigationBar.setBackgroundImage(nil, for: .default)
            navigationBar.shadowImage = nil
        } else {
            navigationBar.setBackgroundImage(UIImage(), for: .default)
            navigationBar.shadowImage = UIImage()
        }
        navigationBar.barStyle = (skin.statusbarMode == .light) ? UIBarStyle.black : .default
    }
    
    public func apply(tabBarSkin: TabBarSkin?, to controller: UITabBarController) {
        guard let skin = tabBarSkin else { return }
        let tabBar = controller.tabBar
        tabBar.isTranslucent = false
        tabBar.barTintColor = skin.barTintColor.uiColor
        tabBar.tintColor = skin.selectedItemTintColor.uiColor
        tabBar.unselectedItemTintColor = skin.itemTintColor.uiColor
    }
    
    public func apply(buttonSkin: ButtonSkin?, to button: UIButton) {
        guard let skin = buttonSkin else { return }
        button.layer.masksToBounds = true
        button.layer.cornerRadius = skin.cornerRadius
        let backgroundColor = skin.backgroundColor.uiColor
        button.setBackgroundColor(color: backgroundColor, forUIControlState: .normal)
        button.setBackgroundColor(color: UIColor.red, forUIControlState: .selected)
        button.setBackgroundColor(color: UIColor.clear, forUIControlState: .highlighted)
        button.setBackgroundColor(color: UIColor.red, forUIControlState: .focused)
        button.setBackgroundColor(color: skin.backgroundColor.disabledColor.uiColor, forUIControlState: .disabled)
        button.setTitleColor(skin.textColor.uiColor, for: .normal)
        button.setTitleColor(skin.textColor.disabledColor.uiColor, for: .disabled)
        button.layer.borderColor = skin.borderColor.cgColor
        button.layer.borderWidth = skin.borderWidth
    }
}
