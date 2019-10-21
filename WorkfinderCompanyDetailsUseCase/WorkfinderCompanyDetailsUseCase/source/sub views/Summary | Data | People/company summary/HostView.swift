
import UIKit
import WorkfinderCommon

class HostView : UIView {
    
    var host: F4SHost? {
        didSet {
            image.image = UIImage(named: "person")
            nameLabel.text = host?.displayName
            roleLabel.text = host?.role
            if let _ = host?.profileUrl {
                profileButton.isHidden = false
                profileButton.setTitle("See more on LinkedIn", for: UIControl.State.normal)
            }
            else {
                profileButton.isHidden = true
            }
        }
    }
    
    var profileLinkTap: ((F4SHost) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(horizontalStack)
        horizontalStack.fillSuperview(padding: UIEdgeInsets(top: 2, left: 0, bottom: 2, right: 0))
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    lazy var horizontalStack: UIStackView = {
        let views = [self.image, self.verticalStack]
        let stack = UIStackView(arrangedSubviews: views)
        stack.axis = .horizontal
        stack.alignment = .top
        stack.spacing = 24
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    lazy var verticalStack: UIStackView = {
        let views = [self.nameLabel, self.roleLabel, self.profileButton]
        let stack = UIStackView(arrangedSubviews: views)
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 8
        stack.distribution = .equalSpacing
        return stack
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.headline)
        return label
    }()
    
    lazy var profileButton: UIButton = {
        let button = UIButton(type: .system)
        //button.setTitleColor(UIColor.black, for: UIControl.State.normal)
        button.setTitle("Profile", for: UIControl.State.normal)
        return button
    }()
    
    lazy var image: UIImageView = {
        let view = UIImageView()
        let height = view.heightAnchor.constraint(equalToConstant: 64)
        height.priority = UILayoutPriority.defaultLow
        view.contentMode = .scaleAspectFit
        view.widthAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        height.isActive = true
        return view
    }()
    
    lazy var roleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.caption1)
        return label
    }()
    
}
