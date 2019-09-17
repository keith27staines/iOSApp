
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
