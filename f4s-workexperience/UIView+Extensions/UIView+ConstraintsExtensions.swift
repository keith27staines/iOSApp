//
//  UIView+ConstraintsExtensions.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 29/08/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit

extension UIView {
    
    /// Adds the specified view as a subview of the current instance
    /// adding constraints to ensure the subview fills the safe area (iOS 11+)
    /// or the area defined by the layout margins for earlier iOS
    func addSubViewToFillSafeArea(view: UIView) {
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
}
