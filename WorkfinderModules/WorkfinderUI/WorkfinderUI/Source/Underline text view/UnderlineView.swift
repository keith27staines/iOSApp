
import UIKit

public class UnderlineView: UIView {
    
    var valueConstraint: NSLayoutConstraint!
    public let goodColor: UIColor
    public let badColor: UIColor
    public let emptyColor: UIColor
    
    public enum State {
        case good
        case bad
        case empty
    }
    
    public var state: State = .empty {
        didSet {
            backgroundColor = color
        }
    }
    
    public var color: UIColor? {
        switch state {
        case .good: return goodColor
        case .bad: return badColor
        case .empty: return backgroundColor
        }
    }
    
    public init(state: State, goodColor: UIColor, badColor: UIColor, emptyColor: UIColor) {
        self.goodColor = goodColor
        self.badColor = badColor
        self.emptyColor = emptyColor
        super.init(frame: CGRect.zero)
        self.backgroundColor = WorkfinderColors.lightGrey
        heightAnchor.constraint(equalToConstant: 2).isActive = true
        self.state = state
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
