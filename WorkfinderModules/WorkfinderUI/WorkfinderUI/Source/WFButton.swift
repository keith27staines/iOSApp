//
//  WFButton.swift
//  WorkfinderUI
//
//  Created by Keith on 10/09/2021.
//  Copyright © 2021 Workfinder. All rights reserved.
//

import UIKit

public class WFButton: UIView {
    
    public var buttonTapped: (() -> Void)?
    public let isSecondary: Bool
    public let isCapsule: Bool
    
    public enum State {
        case normal
        case disabled
        case highlighted
    }
    
    var heightClass: WFCapsuleHeightClass
    
    public var state: State {
        didSet {
            switch isSecondary {
            case true:
                switch state {
                case .normal:
                    backgroundColor = WFColorPalette.white
                    label.textColor = WFColorPalette.readingGreen
                    layer.borderColor = WFColorPalette.readingGreen.cgColor
                case .disabled:
                    backgroundColor = WFColorPalette.gray2
                    label.textColor = WFColorPalette.gray4
                    layer.borderColor = WFColorPalette.readingGreen.cgColor
                case .highlighted:
                    backgroundColor = WFColorPalette.greenTint
                    label.textColor = WFColorPalette.white
                    layer.borderColor = WFColorPalette.readingGreen.cgColor
                }
     
            case false:
                switch state {
                case .normal:
                    backgroundColor = WFColorPalette.readingGreen
                    label.textColor = WFColorPalette.white
                case .disabled:
                    backgroundColor = WFColorPalette.gray2
                    label.textColor = WFColorPalette.gray4
                case .highlighted:
                    backgroundColor = WFColorPalette.greenTint
                    label.textColor = WFColorPalette.white
                }
            }
        }
    }

    private lazy var label: UILabel = {
        let label = UILabel()
        let font = WFTextStyle.standardFont(size: heightClass.fontSize, weight: .bold)
        let style = WFTextStyle(font: font, color: WFColorPalette.white)
        label.applyStyle(style)
        label.textAlignment = .center
        return label
    }()
    
    public var text: String? {
        get { label.text }
        set { label.text = newValue }
    }
    
    public var style: WFTextStyle {
        get { WFTextStyle(font: label.font, color: label.textColor) }
        set {
            label.font = newValue.font
            label.textColor = newValue.color
        }
    }
    
    public init(heightClass: WFCapsuleHeightClass, isCapsule: Bool = true, isSecondary: Bool = false) {
        self.heightClass = heightClass
        self.state = .normal
        self.isCapsule = isCapsule
        self.isSecondary = isSecondary
        super.init(frame: CGRect.zero)
        configureViews()
        self.state = .normal
    }
    
    func configureViews() {
        heightAnchor.constraint(equalToConstant: heightClass.height).isActive = true
        addSubview(label)
        label.anchor(top: nil, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor)
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        layer.cornerRadius = isCapsule ? heightClass.height / 2.0 : 0
        layer.masksToBounds = true
        layer.borderWidth = isSecondary ? 1 : 0
    }
    
    @objc func _tapped(sender: UITapGestureRecognizer)  {
        guard state != .disabled else { return }
        switch sender.state {
        case .began, .changed: state = .highlighted
            
        case .ended:
            state = .normal
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.buttonTapped?()
            }
        default: state = .normal
        }
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard state != .disabled else { return }
        state = .highlighted
        super.touchesBegan(touches, with: event)
    }

    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            self.state = .normal
            self.buttonTapped?()
        }
        super.touchesEnded(touches, with: event)
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        state = .normal
        super.touchesCancelled(touches, with: event)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
