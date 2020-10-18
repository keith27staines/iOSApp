
import UIKit

class CapsuleView: UIView {
    
    var radius: CGFloat
    var string: String?
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = UIColor.darkText
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        return label
    }()
    
    init(string: String, radius: CGFloat = 23) {
        self.string = string
        self.radius = radius
        super.init(frame: CGRect.zero)
        label.text = string
        addSubview(label)
        backgroundColor = UIColor.white
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        widthAnchor.constraint(equalTo: label.widthAnchor, constant: 2 * radius).isActive = true
        heightAnchor.constraint(equalToConstant: 2 * radius).isActive = true
        layoutSubviews()
        layer.masksToBounds = true
        layer.cornerRadius = radius
        layer.borderWidth = 1
        layer.borderColor = UIColor.darkGray.cgColor
        widthAnchor.constraint(equalToConstant: intrinsicContentSize.width).isActive = true
        heightAnchor.constraint(equalToConstant: intrinsicContentSize.height).isActive = true
    }
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: label.intrinsicContentSize.width + 2 * radius, height: 2 * radius)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
