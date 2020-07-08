
import UIKit

public extension UILabel {
    
    @discardableResult
    func constrainToMaxlinesOrFewer(maxLines: Int) -> NSLayoutConstraint {
        let maxLineConstraint = heightAnchor.constraint(lessThanOrEqualToConstant: heightForLines(maxLines))
        maxLineConstraint.priority = .required
        maxLineConstraint.isActive = true
        return maxLineConstraint
    }
    
    func heightForLines(_ n: Int) -> CGFloat{
        let label = UILabel()
        label.font = self.font
        label.text = "Hy"
        label.numberOfLines = 1
        label.sizeToFit()
        return (label.frame.height + 0.1) * CGFloat(n)
    }
}
