

import UIKit
import WorkfinderUI


class HeaderView: UIView {
    
    var height: CGFloat = 66 {
        didSet {
            heightConstraint.constant = height
        }
    }
    lazy var heightConstraint: NSLayoutConstraint = {
        self.heightAnchor.constraint(equalToConstant: height)
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = WorkfinderColors.primaryColor
        heightConstraint.isActive = true
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
