
import UIKit
import WorkfinderUI

class BackgroundView: UIImageView {
    func refresh() {}
    
    init() {
        super.init(frame: CGRect.zero)
        backgroundColor = WorkfinderColors.primaryColor
        isUserInteractionEnabled = true
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
