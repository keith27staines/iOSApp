
import UIKit

public class UnderlinedNextResponderTextField: UIStackView {
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = UIColor.lightGray
        return label
    }()
    
    public var textfield: NextResponderTextField = {
        let nextResponderField = NextResponderTextField()
        nextResponderField.addTarget(self, action: #selector(_textChanged), for: .valueChanged)
        return nextResponderField
    }()
    
    let underline: UnderlineView
    var textChanged: ((String?) -> Void)?
    
    @objc func _textChanged() {
        textChanged?(textfield.text)
    }
    
    public init(fieldName: String,
                goodUnderlineColor: UIColor = UIColor.blue,
                badUnderlineColor: UIColor = UIColor.orange,
                state: UnderlineView.State,
                validator: ((String) -> UnderlineView.State),
                nextResponderField: UIResponder? = nil) {
        underline = UnderlineView(state: state, goodColor: goodUnderlineColor, badColor: badUnderlineColor)
        
        super.init(frame: CGRect.zero)
        self.label.text = fieldName
        textfield.nextResponderField = nextResponderField
        addArrangedSubview(label)
        addArrangedSubview(textfield)
        addArrangedSubview(underline)
        axis = .vertical
    }
    
    required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}


