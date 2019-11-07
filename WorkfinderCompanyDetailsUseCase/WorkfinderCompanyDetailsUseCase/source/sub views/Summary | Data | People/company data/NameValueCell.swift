
import Foundation
import WorkfinderUI

class NameValueCell: UITableViewCell {
    static let reuseIdentifier: String = "NameValueCell"
    var nameValue: NameValueDescriptor = NameValueDescriptor(name: "name", value: "", isButton: false, buttonImage: nil)
    var isLink: Bool = false
    public func configureWithNameValue(_ nameValue: NameValueDescriptor) {
        self.nameValue = nameValue
        self.nameLabel.text = nameValue.name
        self.valueLabel.text = nameValue.value
    }
    
    lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [self.nameLabel, self.valueLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .leading
        stack.distribution = .fillEqually
        return stack
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    lazy var valueLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    lazy var button: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.system)
        return button
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(stack)
        stack.fillSuperview()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
