//
//  IconLabel.swift
//  WorkfinderHome
//
//  Created by Keith on 25/08/2021.
//  Copyright © 2021 Workfinder. All rights reserved.
//

import UIKit

class IconLabel: UIView {
    
    lazy var icon: UIImageView = {
        let icon = UIImageView()
        icon.contentMode = .scaleAspectFit
        icon.heightAnchor.constraint(equalToConstant: 18).isActive = true
        icon.widthAnchor.constraint(equalToConstant: 18).isActive = true
        return icon
    }()
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = UIColor.black
        return label
    }()
    
    lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
                icon,
                label
            ]
        )
        stack.axis = .horizontal
        stack.spacing = 11
        return stack
    }()
    
    init(iconImage: UIImage?) {
        super.init(frame: CGRect.zero)
        self.icon.image = iconImage
        configureViews()
    }
    
    func configureViews() {
        addSubview(stack)
        stack.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
