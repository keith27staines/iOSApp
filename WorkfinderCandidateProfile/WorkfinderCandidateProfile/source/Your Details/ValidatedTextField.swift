//
//  ValidatedTextField.swift
//  WorkfinderCandidateProfile
//
//  Created by Keith Staines on 13/04/2021.
//

import UIKit
import WorkfinderCommon
import WorkfinderUI

public class ValidatedTextFieldStack: UIStackView {
    
    public lazy var textfield: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.systemFont(ofSize: 17)
        textField.addTarget(self, action: #selector(_textChanged), for: .editingChanged)
        textField.heightAnchor.constraint(greaterThanOrEqualToConstant: 20).isActive = true
        return textField
    }()
    
    override public func becomeFirstResponder() -> Bool {
        textfield.becomeFirstResponder()
    }
    
    public lazy var greenTickContainer: UIView = {
        let view = UIView()
        view.addSubview(self.greenTick)
        self.greenTick.translatesAutoresizingMaskIntoConstraints = false
        self.greenTick.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        self.greenTick.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        view.widthAnchor.constraint(equalTo: self.greenTick.widthAnchor).isActive = true
        view.heightAnchor.constraint(greaterThanOrEqualTo: self.greenTick.heightAnchor, multiplier: 1.0).isActive = true
        view.setContentHuggingPriority(.defaultLow, for: .vertical)
        view.setContentHuggingPriority(.required, for: .horizontal)
        return view
    }()
    
    public lazy var greenTick: UIImageView = {
        let image = UIImage(named: "tick")?
            .scaledImage(with: CGSize(width: 15, height: 12))
            .withRenderingMode(.alwaysTemplate)
        let imageView = UIImageView(image: image)
        imageView.tintColor = self.underline.goodColor
        imageView.contentMode = .scaleAspectFit
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        imageView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return imageView
    }()
    
    lazy var textImageStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            self.textfield,
            self.greenTickContainer
        ])
        stack.axis = .horizontal
        stack.spacing = 4
        return stack
    }()
    
    public let underline: UnderlineView
    public var textChanged: ((String?) -> Void)?
    
    @objc func _textChanged() {
        textChanged?(textfield.text)
    }
    
    public var state: UnderlineView.State = .empty {
        didSet {
            setState(state)
        }
    }
    
    func setState(_ state: UnderlineView.State) {
        underline.state = state
        greenTick.isHidden = !(state == .good)
    }
    
    public init(goodUnderlineColor: UIColor = WorkfinderColors.primaryColor,
                badUnderlineColor: UIColor = UIColor.orange,
                emptyUnderlineColor: UIColor = UIColor.gray,
                state: UnderlineView.State
    ) {
        underline = UnderlineView(state: state, goodColor: goodUnderlineColor, badColor: badUnderlineColor, emptyColor: emptyUnderlineColor)
        super.init(frame: CGRect.zero)
        addArrangedSubview(textImageStack)
        addArrangedSubview(underline)
        spacing = 8
        axis = .vertical
        setState(state)
    }
    
    required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
