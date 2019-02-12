//
//  SearchViewFooterView.swift
//  F4SPrototypes
//
//  Created by Keith Dev on 09/02/2019.
//  Copyright © 2019 Keith Staines. All rights reserved.
//

import UIKit

class SearchViewFooterView: UIView {
    
    var tapped: () -> Void
    init(tapped: @escaping () -> Void) {
        self.tapped = tapped
        super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        backgroundColor = UIColor.clear
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        addGestureRecognizer(gestureRecognizer)
    }
    
    @objc private func didTap() { tapped() }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
