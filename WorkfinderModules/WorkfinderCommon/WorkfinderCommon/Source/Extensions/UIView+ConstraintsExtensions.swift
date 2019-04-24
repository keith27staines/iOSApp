//
//  UIView+ConstraintsExtensions.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 29/08/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit

public extension UIView {
    
    /// Adds the specified view as a subview of the current instance
    /// adding constraints to ensure the subview fills the safe area (iOS 11+)
    /// or the area defined by the layout margins for earlier iOS
    public func addSubViewToFillSafeArea(view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        if #available(iOS 11.0, *) {
            view.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor).isActive = true
            view.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor).isActive = true
            view.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
            view.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
        } else {
            // Fallback on earlier versions
            view.leftAnchor.constraint(equalTo: layoutMarginsGuide.leftAnchor).isActive = true
            view.rightAnchor.constraint(equalTo: layoutMarginsGuide.rightAnchor).isActive = true
            view.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor).isActive = true
            view.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor).isActive = true
        }
    }
    
    public func fillSuperview(padding: UIEdgeInsets) {
        anchor(
            top: superview?.topAnchor,
            leading: superview?.leadingAnchor,
            bottom: superview?.bottomAnchor,
            trailing: superview?.trailingAnchor,
            padding: padding)
    }
    
    public func fillSuperview() {
        fillSuperview(padding: .zero)
    }
    
    public func anchorSize(to view: UIView) {
        widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
    }
    
    public func anchor(
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
