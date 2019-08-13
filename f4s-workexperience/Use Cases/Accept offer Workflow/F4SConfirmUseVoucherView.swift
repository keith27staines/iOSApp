//
//  F4SConfirmUseVoucherView.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 24/07/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit
import WorkfinderCommon
import WorkfinderCommon
import WorkfinderUI

class F4SConfirmUseVoucherView: UIView {
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.7)
        whitePanel.alpha = 0.0
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.whitePanel.alpha = 1.0
        }
    }
    
    var result: ((Bool) -> ())? = nil

    var code: String = "" {
        didSet {
            self.codeLabel.text = code
        }
    }
    
    lazy var whitePanel: UIView = {
        let whiteView = UIView(frame: CGRect.zero)
        whiteView.backgroundColor = UIColor.white
        whiteView.translatesAutoresizingMaskIntoConstraints = false
        whiteView.backgroundColor = UIColor.white
        addSubview(whiteView)
        whiteView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        whiteView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        whiteView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 50) .isActive = true
        let topConstraint = whiteView.topAnchor.constraint(equalTo: self.topAnchor, constant: 100)
        topConstraint.priority = UILayoutPriority(250)
        topConstraint.isActive = true
        whiteView.layer.cornerRadius = 10
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        whiteView.addSubview(stack)
        stack.centerXAnchor.constraint(equalTo: whiteView.centerXAnchor).isActive = true
        stack.centerYAnchor.constraint(equalTo: whiteView.centerYAnchor).isActive = true
        stack.leftAnchor.constraint(equalTo: whiteView.leftAnchor, constant: 16) .isActive = true
        stack.topAnchor.constraint(equalTo: whiteView.topAnchor, constant: 16) .isActive = true
        return whiteView
    }()
    
    lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [icon, codeLabel, textLabel, buttonStack])
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        stack.alignment = .fill
        stack.spacing = 20
        return stack
    }()
    
    lazy var icon: UIImageView = {
        let icon = UIImageView()
        icon.image = UIImage(named: "ui-voucher-greenCircle-icon")
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.heightAnchor.constraint(equalToConstant: 60)
        icon.widthAnchor.constraint(equalToConstant: 60)
        icon.contentMode = .scaleAspectFit
        return icon
    }()
    
    lazy var textLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = """
                     Do you want to use this
                     voucher and accept the
                     placement?
                     """
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return label
    }()
    
    lazy var buttonStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [noButton, yesButton])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 40
        return stack
    }()
    
    lazy var yesButton: UIButton = {
        let button = makeButton(title: "Yes", backColor: UIColor.blue, titleColor: UIColor.white)
        button.addTarget(self, action: #selector(performYesAction), for: .touchUpInside)
        Skinner().apply(buttonSkin: skin?.primaryButtonSkin, to: button)
        return button
    }()
    
    lazy var noButton: UIButton = {
        let button = makeButton(title: "No", backColor: UIColor.red, titleColor: UIColor.white)
        button.addTarget(self, action: #selector(performNoAction), for: .touchUpInside)
        Skinner().apply(buttonSkin: skin?.secondaryButtonSkin, to: button)
        return button
    }()
    
    func makeButton(title: String, backColor: UIColor, titleColor: UIColor) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.setTitleColor(titleColor, for: .normal)
        button.addTarget(self, action: #selector(performNoAction), for: .touchUpInside)
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        button.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        button.isEnabled = true
        return button
    }
    
    @objc func performYesAction(sender: UIButton) {
        result?(true)
    }
    
    @objc func performNoAction(sender: UIButton) {
        result?(false)
    }

    lazy var codeLabel: UILabel = {
        let label = UILabel()
        label.text = code
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        label.textColor = RGBA.workfinderPurple.uiColor
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return label
    }()
    
}
