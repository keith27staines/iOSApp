//
//  Skinner.swift
//  Skins
//
//  Created by Keith Dev on 13/08/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit

public protocol Skinning  {
    func apply(skin: Skin?, to controller: UIViewController)
    func apply(buttonSkin: ButtonSkin?, to button: UIButton)
    func apply(navigationBarSkin: NavigationBarSkin?, to controller: UIViewController)
    func apply(tabBarSkin: TabBarSkin?, to controller: UIViewController)
}

public struct Skinner : Skinning {
    
    public func apply(skin: Skin?, to controller: UIViewController) {
        guard let skin = skin else { return }
        apply(navigationBarSkin: skin.navigationBarSkin, to: controller)
        apply(tabBarSkin: skin.tabBarSkin, to: controller)
    }
    
    public func apply(navigationBarSkin: NavigationBarSkin?, to controller: UIViewController) {
        guard let navigationBar =  controller.navigationController?.navigationBar else { return }
        navigationBar.isHidden = false
        guard let skin = navigationBarSkin else {
            navigationBar.isTranslucent = true
            navigationBar.barTintColor = RGBA.white.uiColor
            navigationBar.tintColor = RGBA.black.uiColor
            navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:RGBA.black.uiColor]
            navigationBar.barStyle = .default
            return
        }
        navigationBar.isTranslucent = false
        navigationBar.barTintColor = skin.barTintColor.uiColor
        navigationBar.tintColor = skin.itemTintColor.uiColor
        navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:skin.titleTintColor.uiColor]
        
        navigationBar.barStyle = skin.statusbarMode == .dark ? .black : .default
        if skin.hasDropShadow {
            navigationBar.setBackgroundImage(nil, for: .default)
            navigationBar.shadowImage = nil
        } else {
            navigationBar.setBackgroundImage(UIImage(), for: .default)
            navigationBar.shadowImage = UIImage()
        }
    }
    
    public func apply(tabBarSkin: TabBarSkin?, to controller: UIViewController) {
        guard let skin = tabBarSkin else { return }
        guard let tabBar = controller.tabBarController?.tabBar else { return }
        tabBar.isTranslucent = false
        tabBar.barTintColor = skin.barTintColor.uiColor
        tabBar.tintColor = skin.selectedItemTintColor.uiColor
        tabBar.unselectedItemTintColor = skin.itemTintColor.uiColor
    }
    
    public func apply(buttonSkin: ButtonSkin?, to button: UIButton) {
        guard let skin = buttonSkin else { return }
        button.layer.masksToBounds = true
        button.layer.cornerRadius = skin.cornerRadius
        button.setBackgroundColor(color: skin.backgroundColor.uiColor, forUIControlState: .normal)
        button.setBackgroundColor(color: skin.backgroundColor.disabledColor.uiColor, forUIControlState: .disabled)
        button.setTitleColor(skin.textColor.uiColor, for: .normal)
        button.layer.borderColor = skin.backgroundColor.cgColor
        button.layer.borderColor = skin.borderColor.cgColor
        button.layer.borderWidth = skin.borderWidth
    }
}
