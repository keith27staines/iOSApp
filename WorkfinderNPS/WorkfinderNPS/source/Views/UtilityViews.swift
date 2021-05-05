//
//  UtilityViews.swift
//  WorkfinderNPS
//
//  Created by Keith Staines on 01/05/2021.
//

import UIKit
import WorkfinderUI

class Spacer: UIView {
    
    init(width: CGFloat, height: CGFloat) {
        super.init(frame: CGRect.zero)
        if width > 0 { widthAnchor.constraint(equalToConstant: width).isActive = true }
        if height > 0 { heightAnchor.constraint(equalToConstant: height).isActive = true }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

func makeDivider() -> UIView {
    let view = UIView()
    view.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
    view.backgroundColor = WorkfinderColors.gray4
    return view
}
