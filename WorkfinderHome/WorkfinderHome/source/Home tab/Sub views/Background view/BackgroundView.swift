
import UIKit
import WorkfinderUI

class BackgroundView: UIImageView {
    func refresh() {}
    
    init() {
        super.init(frame: CGRect.zero)
        backgroundColor = UIColor.init(white: 0.9, alpha: 1)
        image = UIImage(named: "home_screen_background")
        isUserInteractionEnabled = true
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
