
import UIKit

public extension UIImageView {
    static func companyLogoImageView(width: CGFloat) -> UIImageView {
        let view = UIImageView()
        view.widthAnchor.constraint(equalToConstant: 70).isActive = true
        view.layer.masksToBounds = true
        view.layer.borderColor = UIColor.init(netHex: 0xE5E5E5).cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 10
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
}
