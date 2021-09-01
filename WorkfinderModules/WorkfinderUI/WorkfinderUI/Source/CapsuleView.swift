
import UIKit

public class CapsuleView: UIView {
    
    var radius: CGFloat
    var string: String?
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = backgroundColor
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = UIColor(red: 0.008, green: 0.188, blue: 0.161, alpha: 1)
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
        backgroundColor = UIColor(red: 0.949, green: 0.949, blue: 0.949, alpha: 1)
        label.text = string
        addSubview(label)
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        widthAnchor.constraint(equalTo: label.widthAnchor, constant: 2 * radius).isActive = true
        let height = heightAnchor.constraint(equalToConstant: 2 * radius)
        height.priority = .defaultHigh
        height.isActive = true
        layoutSubviews()
        layer.masksToBounds = true
        widthAnchor.constraint(equalToConstant: intrinsicContentSize.width).isActive = true
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        label.font = UIFont.systemFont(ofSize: fontSize)
        layer.cornerRadius = radius
    }
    
    var fontSize: CGFloat { max(12, 17/23 * radius) }
    
    public override var intrinsicContentSize: CGSize {
        CGSize(width: label.intrinsicContentSize.width + 2 * radius, height: 2 * radius)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
