//
//  FactorySkins.swift
//  Skins
//
//  Created by Keith Dev on 13/08/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation

public struct FactorySkins {
    
    static func buildButtonSkin(backgroundColor: RGBA) -> ButtonSkin {
        var skin = ButtonSkin()
        skin  = ButtonSkin(cornerRadius: 8, backgroundColor: backgroundColor, textColor: RGBA.white, borderColor: RGBA.black, borderWidth: 2.0)
        return skin
    }
    
    static var skins: Skins = {
        var skins = Skins()
        skins[playgroundSkin.name] = workfinderSkin
        skins[experimentSkin.name] = experimentSkin
        skins[workfinderSkin.name] = workfinderSkin
        skins[ncsSkin.name] = ncsSkin
        skins[nominetSkin.name] = nominetSkin
        return skins
    }()
    
    static var workfinderSkin: Skin = {
        let primaryButtonSkin = buildButtonSkin(backgroundColor: RGBA.workfinderPurple)
        let secondaryButtonSkin = buildButtonSkin(backgroundColor: RGBA.workfinderPink)
        var ghostButtonSkin = buildButtonSkin(backgroundColor: RGBA.clear)
        ghostButtonSkin.textColor = RGBA.gray
        ghostButtonSkin.borderColor = RGBA.gray
        let navigationBarSkin = NavigationBarSkin(statusbarMode: .dark, barTintColor: RGBA.workfinderPurple, itemTintColor: RGBA.white, titleTintColor: RGBA.white, hasDropShadow: false)
        let tabBarSkin = TabBarSkin()
        let skin = Skin(
            name: "workfinder",
            workfinderLogoName: "workfinderLogo",
            partnerLogoName: nil,
            primaryButtonSkin: primaryButtonSkin,
            secondaryButtonSkin: secondaryButtonSkin,
            ghostButtonSkin: ghostButtonSkin,
            navigationBarSkin: navigationBarSkin,
            tabBarSkin: tabBarSkin
        )
        return skin
    }()
    
    static var ncsSkin: Skin = {
        var skin = workfinderSkin
        skin.name = "ncs"
        return skin
    }()
    
    static var nominetSkin: Skin = {
        var skin = workfinderSkin
        skin.name = "nominet"
        return skin
    }()
    
    static var experimentSkin: Skin = {
        var skin = workfinderSkin
        skin.name = "experiment"
        return skin
    }()
    
    static var playgroundSkin: Skin = {
        var skin = workfinderSkin
        skin.name = "playground"
        return skin
    }()
    
}
