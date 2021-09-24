
import UIKit

public protocol Skinning  {
    func apply(buttonSkin: ButtonSkin?, to button: UIButton)
    func apply(navigationBarSkin: NavigationBarSkin?, to controller: UIViewController)
    func apply(tabBarSkin: TabBarSkin?, to controller: UITabBarController)
}

public struct Skinner : Skinning {
    public init() {
    }
    
    public func apply(navigationBarSkin: NavigationBarSkin?, to controller: UIViewController) {
        guard let navigationBar =  controller.navigationController?.navigationBar else {
            return
        }
        navigationBar.isHidden = false
        navigationBar.isTranslucent = false
        navigationBar.barTintColor = UIColor.white
        navigationBar.tintColor = WFColorPalette.readingGreen
        navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:WFColorPalette.readingGreen]
        navigationBar.barStyle = UIBarStyle.black
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
        button.setBackgroundColor(color: backgroundColor.lighter(), forUIControlState: .selected)
        button.setBackgroundColor(color: backgroundColor.lighter().lighter(), forUIControlState: .highlighted)
        button.setBackgroundColor(color: backgroundColor.lighter(), forUIControlState: .focused)
        button.setBackgroundColor(color: RGBA.lightGray.uiColor, forUIControlState: .disabled)
        button.setTitleColor(skin.textColor.uiColor, for: .normal)
        button.setTitleColor(RGBA.gray.uiColor, for: .disabled)
        button.setTitleColor(skin.textColor.disabledColor.uiColor, for: .highlighted)
        button.layer.borderColor = skin.borderColor.cgColor
        button.layer.borderWidth = skin.borderWidth
    }
}
