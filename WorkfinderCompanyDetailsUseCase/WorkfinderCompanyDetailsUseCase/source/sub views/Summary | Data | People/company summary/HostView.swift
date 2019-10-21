
import Foundation
import UIKit

class HostView : UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(verticalStack)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    lazy var verticalStack: UIStackView = {
        let views = [self.nameLabel, self.roleLabel]
        let stack = UIStackView(arrangedSubviews: views)
        stack.axis = .vertical
        return stack
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        return label
    }()
    
    lazy var image: UIImageView = {
        let view = UIImageView()
        let height = view.heightAnchor.constraint(equalToConstant: 64)
        height.priority = UILayoutPriority.defaultHigh
        view.widthAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        height.isActive = true
        return view
    }()
    
    lazy var roleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        return label
    }()
    
}
