
import UIKit

public class UnderlinedNextResponderTextFieldStack: UIStackView {
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.gray
        return label
    }()
    
    public var textfield: NextResponderTextField = {
        let nextResponderField = NextResponderTextField()
        nextResponderField.font = UIFont.systemFont(ofSize: 24)
        nextResponderField.addTarget(self, action: #selector(_textChanged), for: .editingChanged)
        return nextResponderField
    }()
    
    public lazy var greenTickContainer: UIView = {
        let view = UIView()
        view.addSubview(self.greenTick)
        self.greenTick.translatesAutoresizingMaskIntoConstraints = false
        self.greenTick.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        self.greenTick.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        view.widthAnchor.constraint(greaterThanOrEqualTo: self.greenTick.widthAnchor, multiplier: 1).isActive = true
        view.heightAnchor.constraint(greaterThanOrEqualTo: self.greenTick.heightAnchor, multiplier: 1.0).isActive = true
        view.setContentHuggingPriority(.defaultLow, for: .vertical)
        view.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return view
    }()
    
    public lazy var greenTick: UIImageView = {
        let image = UIImage(named: "checkImage")?
            .scaledImage(with: CGSize(width: 24, height: 24))
            .withRenderingMode(.alwaysTemplate)
        let imageView = UIImageView(image: image)
        imageView.tintColor = WorkfinderColors.goodValueActive
        imageView.contentMode = .scaleAspectFit
        imageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        imageView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return imageView
    }()
    
    lazy var textImageStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            self.textfield,
            self.greenTickContainer
        ])
        stack.axis = .horizontal
        stack.spacing = 4
        stack.distribution = .fillProportionally
        return stack
    }()
    
    public let underline: UnderlineView
    public var textChanged: ((String?) -> Void)?
    
    @objc func _textChanged() {
        textChanged?(textfield.text)
    }
    
    public var state: UnderlineView.State = .empty {
        didSet {
            underline.state = state
            greenTick.isHidden = !(state == .good)
        }
    }
    
    public init(fieldName: String,
                goodUnderlineColor: UIColor = UIColor.blue,
                badUnderlineColor: UIColor = UIColor.orange,
                state: UnderlineView.State,
                nextResponderField: UIResponder? = nil) {
        underline = UnderlineView(state: state, goodColor: goodUnderlineColor, badColor: badUnderlineColor)
        super.init(frame: CGRect.zero)
        self.label.text = fieldName
        textfield.nextResponderField = nextResponderField
        addArrangedSubview(label)
        addArrangedSubview(textImageStack)
        addArrangedSubview(underline)
        axis = .vertical
    }
    
    required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}


