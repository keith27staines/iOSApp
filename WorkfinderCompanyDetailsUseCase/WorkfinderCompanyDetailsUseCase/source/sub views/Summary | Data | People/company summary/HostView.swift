
import UIKit
import WorkfinderCommon
import WorkfinderUI

class HostView : UIView {
    
    static let defaultImage = UIImage(named: "noProfilePicture")
    
    var host: F4SHost? {
        didSet {
            image.load(urlString: host?.imageUrl, defaultImage: HostView.defaultImage)
            nameLabel.text = host?.displayName
            roleLabel.text = host?.role
            if let _ = host?.profileUrl {
                profileButton.isHidden = false
                profileButton.setTitle("see more on LinkedIn", for: UIControl.State.normal)
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
        horizontalStack.fillSuperview(padding: UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0))
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
        button.setTitle("Profile", for: UIControl.State.normal)
        button.setImage(UIImage(named:"ui-linkedin-icon")!, for: UIControl.State.normal)
        button.addTarget(self, action: #selector(profileButtonTapped), for: .touchUpInside)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
        return button
    }()
    
    lazy var image: F4SSelfLoadingImageView = {
        let view = F4SSelfLoadingImageView()
        let height = view.heightAnchor.constraint(equalToConstant: 64)
        height.priority = UILayoutPriority.required
        view.contentMode = .scaleAspectFit
        view.widthAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        height.isActive = true
        return view
    }()
    
    lazy var roleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.subheadline)
        return label
    }()
    
    @objc func profileButtonTapped() {
        guard let host = host else { return }
        profileLinkTap?(host)
    }
    
}
