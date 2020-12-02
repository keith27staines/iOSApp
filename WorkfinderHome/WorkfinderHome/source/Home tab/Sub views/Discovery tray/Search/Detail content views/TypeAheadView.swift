
import UIKit
import WorkfinderUI

class TypeAheadView: UIView {
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.text = "Type-ahead List"
        return label
    }()
    
    init() {
        super.init(frame: CGRect.zero)
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
