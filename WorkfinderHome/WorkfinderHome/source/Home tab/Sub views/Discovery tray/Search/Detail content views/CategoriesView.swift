
import UIKit
import WorkfinderUI

class CategoriesView: UIView {
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.text = "Categories view"
        return label
    }()
    
    init() {
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
