
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
    
    func anchor(
        top: NSLayoutYAxisAnchor?,
        leading: NSLayoutXAxisAnchor?,
        bottom: NSLayoutYAxisAnchor?,
        trailing: NSLayoutXAxisAnchor?,
        padding: UIEdgeInsets = .zero,
        size: CGSize = .zero) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: padding.top).isActive = true
        }
        
        if let leading = leading {
            leadingAnchor.constraint(equalTo: leading, constant: padding.left).isActive = true
        }
        
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -padding.bottom).isActive = true
        }
        
        if let trailing = trailing {
            trailingAnchor.constraint(equalTo: trailing, constant: -padding.right).isActive = true
        }
        
        if size.width != 0 {
            widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }
        
        if size.height != 0 {
            heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
    }
}
