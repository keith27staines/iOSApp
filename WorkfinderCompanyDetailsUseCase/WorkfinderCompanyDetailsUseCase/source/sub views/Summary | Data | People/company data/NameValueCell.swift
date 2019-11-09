
import Foundation
import WorkfinderUI

class NameValueCell: UITableViewCell {
    static let reuseIdentifier: String = "NameValueCell"
    
    var nameValue: NameValueDescriptor = NameValueDescriptor(name: "name", value: "", isButton: false, buttonImage: nil)
    var tapAction: ((URL?) -> Void)?
    
    public func configureWithNameValue(_ nameValue: NameValueDescriptor, tapAction: ((URL?) -> Void)? = nil) {
        self.tapAction = tapAction ?? self.tapAction
        self.nameValue = nameValue
        nameLabel.text = nameValue.name
        valueLabel.text = nameValue.value
        button.setTitle(nameValue.value, for: UIControl.State.normal)
        button.setImage(nameValue.buttonImage, for: .normal)
        stack.removeArrangedSubview(valueLabel)
        stack.removeArrangedSubview(buttonContainer)
        valueLabel.removeFromSuperview()
        buttonContainer.removeFromSuperview()
        if nameValue.isButton {
            stack.addArrangedSubview(buttonContainer)
            button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        } else {
            stack.addArrangedSubview(valueLabel)
        }
    }
    
    lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [self.nameLabel, self.valueLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .leading
        stack.distribution = .fillEqually
        return stack
    }()
    
    var textSize: CGFloat = 15
    var lineHeight: CGFloat = 23
    var fontWeight = UIFont.Weight.light
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: self.textSize, weight: self.fontWeight)
        label.numberOfLines = 0
        label.heightAnchor.constraint(greaterThanOrEqualToConstant: self.lineHeight).isActive = true
        return label
    }()
    
    lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: self.textSize, weight: self.fontWeight)
        return label
    }()
    
    lazy var buttonContainer: UIView = {
        let view = UIView()
        view.addSubview(button)
        button.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: nil)
        return view
    }()
    
    var button: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.system)
        let image = UIImage(named: "ui-duedil-icon")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.setTitle("button", for: .normal)
        button.tintColor = UIColor(netHex: 0x027BBB)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.caption1)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        button.heightAnchor.constraint(equalToConstant: 18).isActive = true
        button.setInsets(forContentPadding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), imageTitlePadding: 8)
        return button
    }()
    
    @objc func buttonTapped() {
        tapAction?(nameValue.link)
    }
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(stack)
        stack.fillSuperview()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

extension UIButton {
    func setInsets(
        forContentPadding contentPadding: UIEdgeInsets,
        imageTitlePadding: CGFloat
    ) {
        self.contentEdgeInsets = UIEdgeInsets(
            top: contentPadding.top,
            left: contentPadding.left,
            bottom: contentPadding.bottom,
            right: contentPadding.right + imageTitlePadding
        )
        self.titleEdgeInsets = UIEdgeInsets(
            top: 0,
            left: imageTitlePadding,
            bottom: 0,
            right: -imageTitlePadding
        )
    }
}
