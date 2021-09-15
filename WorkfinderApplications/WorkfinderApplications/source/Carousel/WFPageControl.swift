//
//  WFPageControl.swift
//  WorkfinderApplications
//
//  Created by Keith on 15/09/2021.
//  Copyright © 2021 Workfinder. All rights reserved.
//

import UIKit
import WorkfinderUI

class WFPageControl: UIView {
    private var requiredHeight: CGFloat
    var cornerRadius: CGFloat { requiredHeight/2 - shadowRadius }
    let shadowRadius = CGFloat(4)
    var leftAction: (() -> Void)?
    var rightAction: (() -> Void)?
    
    func applyStyle(_ style: WFTextStyle) {
        label.applyStyle(style)
    }
    
    var pageCount: Int = 5 {
        didSet {
            currentPage = 0
            setText()
        }
    }
    
    var currentPage = 0 {
        didSet {
            setText()
        }
    }
    
    private func setText() {
        leftButton.isEnabled = currentPage > 0
        rightButton.isEnabled = currentPage < pageCount - 1
        label.text = "\(currentPage+1)/\(pageCount)"
    }

    private lazy var leftButtonContainer: UIView = {
        let view = UIView()
        view.addSubview(leftButton)
        leftButton.translatesAutoresizingMaskIntoConstraints = false
        leftButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        leftButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        leftButton.heightAnchor.constraint(equalTo: view.heightAnchor, constant: -2*shadowRadius).isActive = true
        leftButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -2*shadowRadius).isActive = true
        view.heightAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        return view
    }()
    
    private lazy var rightButtonContainer: UIView = {
        let view = UIView()
        view.addSubview(rightButton)
        rightButton.translatesAutoresizingMaskIntoConstraints = false
        rightButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        rightButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        rightButton.heightAnchor.constraint(equalTo: view.heightAnchor, constant: -2*shadowRadius).isActive = true
        rightButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -2*shadowRadius).isActive = true
        view.heightAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        return view
    }()
    
    private lazy var leftButton: UIButton = {
        let button = UIButton()
        button.setTitle("<", for: .normal)
        button.setTitleColor(WFColorPalette.graphicsGreen, for: .normal)
        button.setTitleColor(WFColorPalette.gray1, for: .disabled)
        button.addTarget(self, action: #selector(leftButtonTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var rightButton: UIButton = {
        let button = UIButton()
        button.setTitle(">", for: .normal)
        button.setTitleColor(WFColorPalette.graphicsGreen, for: .normal)
        button.setTitleColor(WFColorPalette.gray1, for: .disabled)
        button.addTarget(self, action: #selector(rightButtonTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var mainStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            leftButtonContainer,
            label,
            rightButtonContainer
        ])
        stack.spacing = 0
        stack.axis = .horizontal
        return stack
    }()
    
    @objc private func leftButtonTap() {
        leftAction?()
    }
    @objc private func rightButtonTap() {
        rightAction?()
    }

    private lazy var label: UILabel = {
        let label = UILabel()
        label.text = "1/5"
        var style = WFTextStyle.smallLabelTextRegular
        style.color = WFColorPalette.offBlack
        label.applyStyle(style)
        label.textAlignment = .center
        return label
    }()
    
    init(height: CGFloat, leftAction: @escaping () -> Void, rightAction: @escaping () -> Void) {
        self.requiredHeight = height
        self.leftAction = leftAction
        self.rightAction = rightAction
        super.init(frame: CGRect.zero)
        addSubview(mainStack)
        mainStack.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
        widthAnchor.constraint(equalToConstant: 3 * height).isActive = true
        leftButtonContainer.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1/3).isActive = true
        rightButtonContainer.widthAnchor.constraint(equalTo: leftButtonContainer.widthAnchor).isActive = true
        leftButton.makeRoundedAndShadowed(cornerRadius: cornerRadius, shadowRadius: shadowRadius)
        rightButton.makeRoundedAndShadowed(cornerRadius: cornerRadius, shadowRadius: shadowRadius)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UIView {
    
    func makeRoundedAndShadowed(cornerRadius: CGFloat, shadowRadius: CGFloat) {
        let shadowLayer = CAShapeLayer()
        layer.cornerRadius = cornerRadius
        layer.borderWidth = 0.5
        layer.borderColor = WFColorPalette.offWhite.cgColor
        layer.masksToBounds = true
        shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
        shadowLayer.fillColor = UIColor.clear.cgColor
        shadowLayer.shadowColor = UIColor.black.cgColor
        shadowLayer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        shadowLayer.shadowOpacity = 0.85
        shadowLayer.shadowRadius = shadowRadius
        layer.insertSublayer(shadowLayer, at: 0)
    }
}
