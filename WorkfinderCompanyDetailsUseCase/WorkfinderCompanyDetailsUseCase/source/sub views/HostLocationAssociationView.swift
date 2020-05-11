
import UIKit
import WorkfinderCommon
import WorkfinderUI

class HostLocationAssociationView : UIView {
    
    static let defaultImage = UIImage(named: "noProfilePicture")
    var textSize: CGFloat = 15
    var lineHeight: CGFloat = 23
    var fontWeight = UIFont.Weight.light
    
    var association: HostLocationAssociationJson? {
        didSet {
            image.load(urlString: association?.host.photoUrlString, defaultImage: HostLocationAssociationView.defaultImage)
            nameLabel.text = association?.host.displayName
            roleLabel.text = association?.title
            expandableLabel.text = association?.host.description ?? "Description text"
            
            if let _ = association?.host.linkedinUrlString {
                profileButton.isHidden = false
                profileButton.setTitle("see more on LinkedIn", for: UIControl.State.normal)
            } else {
                profileButton.isHidden = true
            }
            associationSelectionView.isSelected = association?.isSelected ?? false
        }
    }
    
    var expandableLabelState = ExpandableLabelState() {
        didSet {
            expandableLabel.state = expandableLabelState
            readMoreLabel.text = expandableLabelState.isExpanded ? "Close" : "Read more"
            readMoreLabelStack.isHidden = !self.expandableLabel.isExpandable
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        readMoreLabelStack.isHidden = !self.expandableLabel.isExpandable
    }
    
    var profileLinkTap: ((HostLocationAssociationJson) -> Void)?
    
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
    
    var selectAction: (((HostSelectionView) -> Void))? {
        didSet {
            self.associationSelectionView.tapAction = selectAction
        }
    }
    
    lazy var associationSelectionView: HostSelectionView = {
        let view = HostSelectionView(selectAction: self.selectAction)
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    lazy var horizontalStack: UIStackView = {
        let views = [self.associationSelectionView ,self.image, self.verticalStack]
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
        guard let association = association else { return }
        profileLinkTap?(association)
    }
    
}

struct ExpandableLabelState {
    var text: String = ""
    var isExpanded: Bool = false
    var isExpandable: Bool =  false
}

class ExpandableLabel: UILabel {
    
    override var text: String? {
        set {
            super.text = newValue
            updateHeight()
        }
        get {
            return super.text
        }
    }
    
    func expand() {
        state.isExpanded = true
        updateHeight()
    }
    
    var state = ExpandableLabelState() {
        didSet {
            self.updateHeight()
        }
    }

    func updateHeight() {
        guard let text = self.text, text.isEmpty == false else {
            self.numberOfLines = 1
            self.heightConstraint.constant = 0
            return
        }
        numberOfLines = lines
        heightConstraint.constant = state.isExpanded ? expandedHeight: collapsedHeight
    }
    
    private var expandedHeight: CGFloat { return CGFloat(lines) * lineHeight }
    private var collapsedHeight: CGFloat { return lineHeight }
    private var lineHeight: CGFloat { return font.lineHeight }
    
    override func layoutMarginsDidChange() {
        updateHeight()
    }
    
    var isExpandable: Bool {
        return lines > 1
    }
    
    private var lines: Int {
        guard let text = self.text, text.isEmpty == false else { return 0 }
        let maxSize = CGSize(width: bounds.size.width, height: CGFloat(Float.infinity))
        let charSize = font.lineHeight
        let nsText = text as NSString
        let textSize = nsText.boundingRect(with: maxSize, options: [.usesLineFragmentOrigin], attributes: [NSAttributedString.Key.font: font!], context: nil)
        let linesRoundedUp = Int(ceil(textSize.height/charSize))
        return linesRoundedUp
    }
    
    private lazy var heightConstraint: NSLayoutConstraint = {
        let constraint = heightAnchor.constraint(equalToConstant: 0)
        constraint.priority = UILayoutPriority.defaultHigh
        constraint.isActive = true
        return constraint
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        numberOfLines = 0
        lineBreakMode = .byWordWrapping
        font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.caption1)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class HostSelectionView: UIView {
    
    lazy var circleImageView: UIImageView = {
        let diameter = CGFloat(32)
        let frame = CGRect(origin: CGPoint.zero, size: CGSize(width: diameter, height: diameter))
        let view = UIImageView(frame: frame)
        view.layer.borderWidth = 1
        view.layer.masksToBounds = false
        view.layer.borderColor = UIColor.darkGray.cgColor
        view.layer.cornerRadius = frame.height/2
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        view.heightAnchor.constraint(equalToConstant: diameter).isActive = true
        view.widthAnchor.constraint(equalToConstant: diameter).isActive = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(buttonTap))
        view.addGestureRecognizer(tap)
        view.addSubview(self.buttonCenterView)
        self.buttonCenterView.translatesAutoresizingMaskIntoConstraints = false
        self.buttonCenterView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        self.buttonCenterView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        return view
    }()
    
    lazy var buttonCenterView: UIImageView = {
        let diameter = CGFloat(24)
        let frame = CGRect(origin: CGPoint.zero, size: CGSize(width: diameter, height: diameter))
        let view = UIImageView(frame: frame)
        view.layer.borderWidth = 0
        view.layer.masksToBounds = false
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.cornerRadius = frame.height/2
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: diameter).isActive = true
        view.widthAnchor.constraint(equalToConstant: diameter).isActive = true
        return view
    }()
    
    var tapAction: ((HostSelectionView) -> Void)?
    
    var isSelected: Bool = false {
        didSet {
            switch isSelected {
            case true:
                buttonCenterView.layer.backgroundColor = WorkfinderColors.primaryColor.cgColor
            case false:
                buttonCenterView.layer.backgroundColor = UIColor.white.cgColor
            }
        }
    }
    
    override var intrinsicContentSize: CGSize { return CGSize(width: 36, height: 64)}
    
    @objc func buttonTap() {
        tapAction?(self)
    }
    
    init(selectAction: ((HostSelectionView) -> Void)?) {
        super.init(frame: CGRect.zero)
        self.tapAction = selectAction
        addSubview(circleImageView)
        circleImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        circleImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        isUserInteractionEnabled = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func contentHuggingPriority(for axis: NSLayoutConstraint.Axis) -> UILayoutPriority {
        switch axis {
        case .horizontal:
            return .defaultHigh
        case .vertical:
            return UILayoutPriority.init(rawValue: 0)
        @unknown default:
            return .defaultHigh
        }
    }
    
}

