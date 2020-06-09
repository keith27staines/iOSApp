
import UIKit

fileprivate var skins: Skins = Skin.loadSkins()

public extension UIViewController {
    
    var skin: Skin? { return skins["workfinder"] }

    var splashColor: UIColor {
        return skin?.navigationBarSkin.barTintColor.uiColor ?? UIColor.white
    }
    
    func styleNavigationController() {
        Skinner().apply(navigationBarSkin: skin?.navigationBarSkin, to: self)
        setNeedsStatusBarAppearanceUpdate()
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
