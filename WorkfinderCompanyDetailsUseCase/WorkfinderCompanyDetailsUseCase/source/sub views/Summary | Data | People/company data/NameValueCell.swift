
import Foundation
import WorkfinderUI

class NameValueCell: UITableViewCell {
    static let reuseIdentifier: String = "NameValueCell"
    
    var nameValue: NameValueDescriptor = NameValueDescriptor(name: "name", value: "", isButton: false, buttonImage: nil)
    var isLink: Bool = false
    var duedilTap: (() -> Void)?
    
    public func configureWithNameValue(_ nameValue: NameValueDescriptor, duedilTap: @escaping () -> Void) {
        self.duedilTap = duedilTap
        self.nameValue = nameValue
        self.nameLabel.text = nameValue.name
        stack.removeArrangedSubview(valueLabel)
        stack.removeArrangedSubview(buttonContainer)
        valueLabel.removeFromSuperview()
        buttonContainer.removeFromSuperview()
        if nameValue.isButton {
            button.setTitle(nameValue.value, for: UIControl.State.normal)
            button.setImage(nameValue.buttonImage, for: .normal)
            stack.addArrangedSubview(buttonContainer)
        } else {
            valueLabel.text = nameValue.value
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
        label.heightAnchor.constraint(equalToConstant: self.lineHeight).isActive = true
        return label
    }()
    
    lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: self.textSize, weight: self.fontWeight)
        label.heightAnchor.constraint(equalToConstant: self.lineHeight).isActive = true
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
        let image = UIImage(named: "ui-duedil-icon")
        button.setImage(image, for: .normal)
        button.setTitle("button", for: .normal)
        button.setTitleColor(UIColor.blue, for: .normal)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.caption1)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
        return button
    }()
    
    @objc func buttonTapped() {
        duedilTap?()
    }
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(stack)
        stack.fillSuperview()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
