
import UIKit

fileprivate var skins: Skins = Skin.loadSkins()

public extension UIViewController {
    
    var skin: Skin? { return skins["workfinder"] }

    var splashColor: UIColor {
        return skin?.navigationBarSkin.barTintColor.uiColor ?? UIColor.white
    }
    
    func styleNavigationController() {
        guard let navigationBar =  navigationController?.navigationBar else { return }
        navigationBar.isHidden = false
        navigationBar.isTranslucent = false
        navigationBar.barTintColor = UIColor.white
        navigationBar.tintColor = WFColorPalette.readingGreen
        navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:WFColorPalette.readingGreen]
        //navigationBar.barStyle = UIBarStyle.black
        if #available(iOS 15.0, *) {
            updateNavigationStyle()
        }
        setNeedsStatusBarAppearanceUpdate()
    }
    
    @available(iOS 15.0, *)
    private func updateNavigationStyle() {
        guard let navigationBar = navigationController?.navigationBar
        else { return }
        navigationBar.isHidden = false
        let barAppearance = UINavigationBarAppearance()
        barAppearance.backgroundColor = .white
        barAppearance.titleTextAttributes = [.foregroundColor: WFColorPalette.readingGreen]
        navigationBar.tintColor = WFColorPalette.readingGreen
        navigationBar.standardAppearance = barAppearance
        navigationBar.scrollEdgeAppearance = barAppearance
    }
}

public extension UIViewController{
    var previousViewController:UIViewController?{
        if let controllersOnNavStack = self.navigationController?.viewControllers{
            let n = controllersOnNavStack.count
            //if self is still on Navigation stack
            if controllersOnNavStack.last === self, n > 1{
                return controllersOnNavStack[n - 2]
            }else if n > 0{
                return controllersOnNavStack[n - 1]
            }
        }
        return nil
    }
}
