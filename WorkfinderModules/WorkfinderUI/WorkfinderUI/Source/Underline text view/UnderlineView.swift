
import UIKit

public class UnderlineView: UIView {
    
    var valueConstraint: NSLayoutConstraint!
    let goodColor: UIColor
    let badColor: UIColor
    
    lazy var lineView: UIView = {
        let view = UIView()
        return view
    }()
    
    public enum State {
        case good
        case bad
        case empty
    }
    
    public var state: State = .empty {
        didSet {
            lineView.backgroundColor = color
            UIView.animate(withDuration: 0.3) {
                self.valueConstraint.constant = self.state == .empty ? 0.0 : 1.0
            }
        }
    }
    
    var color: UIColor? {
        switch state {
        case .good: return goodColor
        case .bad: return badColor
        case .empty: return backgroundColor
        }
    }
    
    public init(state: State, goodColor: UIColor, badColor: UIColor) {
        self.goodColor = goodColor
        self.badColor = badColor
        super.init(frame: CGRect.zero)
        addSubview(lineView)
        lineView.anchor(top: self.topAnchor,
                        leading: self.leadingAnchor,
                        bottom: self.bottomAnchor,
                        trailing: nil)
        lineView.heightAnchor.constraint(equalToConstant: 2).isActive = true
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
