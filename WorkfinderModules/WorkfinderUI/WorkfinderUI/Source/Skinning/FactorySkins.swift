
import Foundation

public struct FactorySkins {
    
    static func buildButtonSkin(backgroundColor: RGBA) -> ButtonSkin {
        var skin = ButtonSkin()
        skin  = ButtonSkin(cornerRadius: 8, backgroundColor: backgroundColor, textColor: RGBA.white, borderColor: RGBA.black, borderWidth: 0.0)
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
        var primaryButtonSkin = buildButtonSkin(backgroundColor: RGBA.workfinderPurple)
        primaryButtonSkin.backgroundColor = RGBA.workfinderPurple
        primaryButtonSkin.borderColor = RGBA.clear
        primaryButtonSkin.borderWidth = 0.0
        primaryButtonSkin.textColor = RGBA.white
        
        var secondaryButtonSkin = buildButtonSkin(backgroundColor: RGBA.clear)
        secondaryButtonSkin.backgroundColor = RGBA.clear
        secondaryButtonSkin.borderColor = RGBA.workfinderPurple
        secondaryButtonSkin.textColor = RGBA.workfinderPurple
        secondaryButtonSkin.borderWidth = 1
        
        var ghostButtonSkin = buildButtonSkin(backgroundColor: RGBA.clear)
        ghostButtonSkin.backgroundColor = RGBA.clear
        ghostButtonSkin.textColor = RGBA.white
        ghostButtonSkin.borderColor = RGBA.white
        ghostButtonSkin.borderWidth = 1
        
        var navigationBarSkin = NavigationBarSkin(statusbarMode: .dark, barTintColor: RGBA.workfinderGreen, itemTintColor: RGBA.white, titleTintColor: RGBA.white, hasDropShadow: false)
        navigationBarSkin.statusbarMode = .light
        
        var tabBarSkin = TabBarSkin()
        tabBarSkin.barTintColor = RGBA.white
        tabBarSkin.itemTintColor = RGBA.lightGray
        tabBarSkin.selectedItemTintColor = RGBA.black
        
        var skin = Skin(
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
    
    
//    NCS colours are: primary navbar.background - #252a2e, rgb(37, 42, 46) + primary.cta.background  cta - #ea148c, rgb(234, 20, 140).
//
//    Secondary ghost dark = black
    
    static var ncsSkin: Skin = {
        var skin = workfinderSkin
        skin.name = "ncs"
        skin.navigationBarSkin.barTintColor = RGBA(red: 37.0/255.0, green: 42.0/255.0, blue: 46.0/255.0, alpha: 1.0)
        skin.primaryButtonSkin.backgroundColor = RGBA(red: 234.0/255.0, green: 20.0/255.0, blue: 140.0/255.0, alpha: 1.0)
        skin.secondaryButtonSkin.backgroundColor = RGBA.clear
        skin.secondaryButtonSkin.borderColor = RGBA.black
        skin.secondaryButtonSkin.textColor = RGBA.black
        skin.secondaryButtonSkin.borderWidth = 1
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
