//
//  WFButton.swift
//  WorkfinderUI
//
//  Created by Keith on 10/09/2021.
//  Copyright © 2021 Workfinder. All rights reserved.
//

import UIKit

public class WFButton: UIView {
    
    var buttonTapped: (() -> Void)?
    
    public enum State {
        case normal
        case disabled
        case highlighted
        
        var backgroundColor: UIColor {
            switch self {
            case .normal: return WFColorPalette.readingGreen
            case .disabled: return WFColorPalette.gray2
            case .highlighted: return WFColorPalette.greenTint
            }
        }
    }
    
    var heightClass: WFCapsuleHeightClass
    
    public var state: State {
        didSet {
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
    
    private lazy var label: UILabel = {
        let label = UILabel()
        let font = WFTextStyle.standardFont(size: heightClass.fontSize, weight: .regular)
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
    
    public init(heightClass: WFCapsuleHeightClass, isCapsule: Bool = true) {
        self.heightClass = heightClass
        self.state = .normal
        super.init(frame: CGRect.zero)
        heightAnchor.constraint(equalToConstant: heightClass.height).isActive = true
        layer.cornerRadius = isCapsule ? heightClass.height / 2.0 : 0
        layer.masksToBounds = true
    }
    
    func configureViews() {
        addSubview(label)
        label.anchor(top: nil, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor)
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(_tapped)))
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
    
//    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard state != .disabled else { return }
//        state = .highlighted
//    }
//
//    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        <#code#>
//    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
