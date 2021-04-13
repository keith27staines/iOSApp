
import UIKit

public class UnderlineView: UIView {
    
    var valueConstraint: NSLayoutConstraint!
    public let goodColor: UIColor
    public let badColor: UIColor
    
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
            let width = self.bounds.size.width
            self.valueConstraint.constant = self.state == .empty ? 0.0 : width
            UIView.animate(withDuration: 0.3) {
                self.layoutIfNeeded()
                self.lineView.layoutIfNeeded()
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
        self.backgroundColor = WorkfinderColors.lightGrey
        addSubview(lineView)
        lineView.anchor(top: self.topAnchor,
                        leading: self.leadingAnchor,
                        bottom: self.bottomAnchor,
                        trailing: nil)

        underlineHeight.isActive = true
        valueConstraint = lineView.widthAnchor.constraint(equalToConstant: 1)
        valueConstraint.isActive = true
    }
    
    lazy var underlineHeight: NSLayoutConstraint = {
        let constraint = lineView.heightAnchor.constraint(equalToConstant: 2)
        constraint.priority = .defaultHigh
        return constraint
    }()
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
