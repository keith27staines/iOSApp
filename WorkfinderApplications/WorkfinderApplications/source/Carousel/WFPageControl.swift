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
            // currentPageIndex = 0
            setText()
        }
    }
    
    var currentPageIndex = 0 {
        didSet {
            setText()
        }
    }
    
    private func setText() {
        leftButton.isEnabled = currentPageIndex > 0
        rightButton.isEnabled = currentPageIndex < pageCount - 1
        label.text = "\(currentPageIndex+1)/\(pageCount)"
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
    
    private lazy var leftButton: WFFloatingButton = {
        let button = WFFloatingButton()
        let normalImage = UIImage(systemName: "chevron.left")?.withTintColor(WFColorPalette.graphicsGreen, renderingMode: .alwaysOriginal)
        let disabledImage = UIImage(systemName: "chevron.left")?.withTintColor(WFColorPalette.offWhite, renderingMode: .alwaysOriginal)
        button.setImage(normalImage, for: .normal)
        button.setImage(disabledImage, for: .disabled)
        button.addTarget(self, action: #selector(leftButtonTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var rightButton: WFFloatingButton = {
        let button = WFFloatingButton()        
        let normalImage = UIImage(systemName: "chevron.right")?.withTintColor(WFColorPalette.graphicsGreen, renderingMode: .alwaysOriginal)
        let disabledImage = UIImage(systemName: "chevron.right")?.withTintColor(WFColorPalette.offWhite, renderingMode: .alwaysOriginal)
        button.setImage(normalImage, for: .normal)
        button.setImage(disabledImage, for: .disabled)
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

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



