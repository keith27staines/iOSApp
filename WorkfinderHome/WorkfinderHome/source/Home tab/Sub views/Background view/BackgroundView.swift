
import UIKit
import WorkfinderUI

class BackgroundView: UIView {
    func refresh() {}
    
    init() {
        super.init(frame: CGRect.zero)
        backgroundColor = UIColor.init(white: 0.9, alpha: 1)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
