
import UIKit

public extension UIView {
    
    /// Adds the specified view as a subview of the current instance
    /// adding constraints to ensure the subview fills the safe area (iOS 11+)
    /// or the area defined by the layout margins for earlier iOS
    func addSubViewToFillSafeArea(view: UIView) {
        addSubview(view)
        view.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor).isActive = true
        view.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor).isActive = true
        view.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func fillSuperview(padding: UIEdgeInsets) {
        anchor(
            top: superview?.topAnchor,
            leading: superview?.leadingAnchor,
            bottom: superview?.bottomAnchor,
            trailing: superview?.trailingAnchor,
            padding: padding)
    }
    
    func fillSuperview() {
        fillSuperview(padding: .zero)
    }
    
    func anchorSize(to view: UIView) {
        widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
    }
    
    @discardableResult func anchor(
        top: NSLayoutYAxisAnchor?,
        leading: NSLayoutXAxisAnchor?,
        bottom: NSLayoutYAxisAnchor?,
        trailing: NSLayoutXAxisAnchor?,
        padding: UIEdgeInsets = .zero,
        size: CGSize = .zero) -> (NSLayoutConstraint?,
                                  NSLayoutConstraint?,
                                  NSLayoutConstraint?,
                                  NSLayoutConstraint?,
                                  NSLayoutConstraint?,
                                  NSLayoutConstraint?
        ) {
        translatesAutoresizingMaskIntoConstraints = false
        var topConstraint: NSLayoutConstraint? = nil
        var leadingConstraint: NSLayoutConstraint? = nil
        var bottomConstraint: NSLayoutConstraint? = nil
        var trailingConstraint: NSLayoutConstraint? = nil
        var widthConstraint: NSLayoutConstraint? = nil
        var heightConstraint: NSLayoutConstraint? = nil

        if let top = top {
            topConstraint = topAnchor.constraint(equalTo: top, constant: padding.top)
        }
        
        if let leading = leading {
            leadingConstraint = leadingAnchor.constraint(equalTo: leading, constant: padding.left)
        }
        
        if let bottom = bottom {
            bottomConstraint = bottomAnchor.constraint(equalTo: bottom, constant: -padding.bottom)
        }
        
        if let trailing = trailing {
            trailingConstraint = trailingAnchor.constraint(equalTo: trailing, constant: -padding.right)
        }
        
        if size.width != 0 {
            widthConstraint = widthAnchor.constraint(equalToConstant: size.width)
        }
        
        if size.height != 0 {
            heightConstraint = heightAnchor.constraint(equalToConstant: size.height)
        }
        let constraints = [topConstraint, leadingConstraint, bottomConstraint,trailingConstraint, widthConstraint, heightConstraint]
        constraints.forEach { (constraint) in
            constraint?.priority = UILayoutPriority(999)
            constraint?.isActive = true
        }
        return (topConstraint, leadingConstraint, bottomConstraint, trailingConstraint, widthConstraint, heightConstraint)
    }
}
