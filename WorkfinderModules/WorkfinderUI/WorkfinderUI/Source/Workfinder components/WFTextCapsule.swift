//
//  WFCapsule.swift
//  WorkfinderUI
//
//  Created by Keith on 08/09/2021.
//  Copyright © 2021 Workfinder. All rights reserved.
//

import UIKit

public class WFTextCapsule: UIView {
    
    var heightClass: WFComponentsHeightClass
    var radius: CGFloat { height / 2.0 }
    
    public var text: String? {
        get { label.text }
        set { label.text = newValue}
    }
    
    lazy var heightConstraint: NSLayoutConstraint = {
        heightAnchor.constraint(equalToConstant: height)
    }()
    
    var height: CGFloat {
        switch heightClass {
        case .small: return 24
        case .larger: return 32
        case .clickable: return 44
        }
    }

    lazy var label: UILabel = {
        let label = UILabel()
        return label
    }()
    
    lazy var leadingImageView: UIImageView = {
        let view = UIImageView()
        return view
    }()

    lazy var trailingImageView: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    lazy var content: UIStackView = {
        let stack = UIStackView()
        return stack
    }()

    public init(
        heightClass: WFComponentsHeightClass,
        borderWidth: CGFloat,
        borderColor: UIColor,
        backgroundColor: UIColor,
        textStyle: WFTextStyle,
        text: String? = nil
    ) {
        self.heightClass = heightClass
        super.init(frame: CGRect.zero)
        configureViews()
        self.text = text
        styleControl(
            borderWidth: borderWidth,
            borderColor: borderColor,
            backgroundColor: backgroundColor,
            textStyle: textStyle
        )
    }
    
    var labelLeadingConstraint: NSLayoutConstraint?
    
    func configureViews() {
        addSubview(label)
        label.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        let labelLeadingConstraint = label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: radius)
        NSLayoutConstraint.activate([labelLeadingConstraint])
        self.labelLeadingConstraint = labelLeadingConstraint
    }
    
    public func setColors(backgroundColor: UIColor, borderColor: UIColor, textColor: UIColor) {
        label.textColor = textColor
        layer.backgroundColor = backgroundColor.cgColor
        layer.borderColor = borderColor.cgColor
    }
    
    func styleControl(
        borderWidth: CGFloat,
        borderColor: UIColor,
        backgroundColor: UIColor,
        textStyle: WFTextStyle
    ) {
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor
        layer.masksToBounds = true
        label.applyStyle(textStyle)
    }
    
    public override func layoutSubviews() {
        layer.cornerRadius = radius
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

