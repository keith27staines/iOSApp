
import UIKit
import WorkfinderCommon
import WorkfinderUI

class HostView : UIView {
    
    static let defaultImage = UIImage(named: "noProfilePicture")
    var textSize: CGFloat = 15
    var lineHeight: CGFloat = 23
    var fontWeight = UIFont.Weight.light
    
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
    
    var expandableLabelState = ExpandableLabelState() {
        didSet {
            expandableLabel.state = expandableLabelState
            readMoreLabel.text = expandableLabelState.isExpanded ? "close" : "Read more"
            readMoreLabelStack.isHidden = !self.expandableLabel.isExpandable
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        readMoreLabelStack.isHidden = !self.expandableLabel.isExpandable
    }
    
    var profileLinkTap: ((F4SHost) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(fullStack)
        fullStack.fillSuperview(padding: UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0))
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    lazy var expandableLabel: ExpandableLabel = {
        let label = ExpandableLabel()
        label.font = UIFont.systemFont(ofSize: self.textSize, weight: self.fontWeight)
        return label
    }()
    
    lazy var readMoreLabelStack: UIStackView = {
        let spacingView = UIView()
        spacingView.setContentHuggingPriority(UILayoutPriority.defaultLow, for: .horizontal)
        let stack = UIStackView(arrangedSubviews: [UIView(), self.readMoreLabel])
        stack.axis = .horizontal
        stack.distribution = .fill
        return stack
    }()
    
    lazy var readMoreLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.widthAnchor.constraint(equalToConstant: 100).isActive = true
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: self.textSize, weight: .bold)
        label.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .horizontal)
        label.textAlignment = .center
        label.layer.masksToBounds = true
        return label
    }()
    
    lazy var fullStack: UIStackView = {
        let views = [self.horizontalStack, self.expandableLabel, self.readMoreLabelStack]
        let stack = UIStackView(arrangedSubviews: views)
        stack.spacing = 4
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.distribution = .fill
        return stack
    }()
    
    lazy var horizontalStack: UIStackView = {
        let views = [self.image, self.verticalStack]
        let stack = UIStackView(arrangedSubviews: views)
        stack.axis = .horizontal
        stack.alignment = .top
        stack.spacing = 12
        return stack
    }()
    
    lazy var verticalStack: UIStackView = {
        let views = [self.nameLabel, self.roleLabel, self.profileButton]
        let stack = UIStackView(arrangedSubviews: views)
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 4
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
        let tintColor = UIColor(netHex: 0x027BBB)
        button.setTitle("Profile", for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.caption1)
        var image = UIImage(named:"ui-linkedin-icon")!.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        button.setImage(image, for: UIControl.State.normal)
        button.tintColor = tintColor
        button.addTarget(self, action: #selector(profileButtonTapped), for: .touchUpInside)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
        return button
    }()
    
    lazy var image: F4SSelfLoadingImageView = {
        let view = F4SSelfLoadingImageView()
        view.layer.cornerRadius = 6
        view.layer.masksToBounds = true
        let height = view.heightAnchor.constraint(equalToConstant: 64)
        height.priority = UILayoutPriority.required
        view.contentMode = .scaleAspectFit
        view.widthAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        height.isActive = true
        return view
    }()
    
    lazy var roleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.caption1)
        return label
    }()
    
    @objc func profileButtonTapped() {
        guard let host = host else { return }
        profileLinkTap?(host)
    }
    
}

struct ExpandableLabelState {
    var text: String = ""
    var isExpanded: Bool = false
    var isExpandable: Bool =  false
}

class ExpandableLabel: UILabel {
    
    var state = ExpandableLabelState() {
        didSet {
            self.text = state.text
            heightConstraint.constant = state.isExpanded ? displayHeight + lineHeight: minHeight
        }
    }
    
    private var minHeight: CGFloat { return 2 * lineHeight }
    private var requiredHeight: CGFloat { return CGFloat(lines) * lineHeight }
    private var displayHeight: CGFloat { return max(requiredHeight, minHeight) }
    private var lineHeight: CGFloat { return font.lineHeight }
    
    override func layoutMarginsDidChange() {
        heightConstraint.constant = state.isExpanded ? displayHeight : minHeight
    }
    
    var isExpandable: Bool {
        return lines > 2
    }
    
    private var lines: Int {
        let maxSize = CGSize(width: bounds.size.width, height: CGFloat(Float.infinity))
        let charSize = font.lineHeight
        let text = (self.text ?? "Summary") as NSString
        let textSize = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font!], context: nil)
        let linesRoundedUp = Int(ceil(textSize.height/charSize))
        return linesRoundedUp
    }
    
    private lazy var heightConstraint: NSLayoutConstraint = {
        let constraint = heightAnchor.constraint(equalToConstant: self.minHeight)
        constraint.priority = UILayoutPriority.defaultHigh
        constraint.isActive = true
        return constraint
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        numberOfLines = 0
        font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.caption1)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
