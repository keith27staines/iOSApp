//
//  ApplicationLetterViewControllerView.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 24/03/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import UIKit
import WorkfinderCommon

class ApplicationLetterViewControllerMainView: UIView {
    
    var termsAndConditionsButton: UIButton = {
        let button = UIButton()
        button.isHidden = false
        button.translatesAutoresizingMaskIntoConstraints = false
        let termsAndConditionsApplyText = NSLocalizedString("By applying you are agreeing to our ", comment: "")
        let termsAndConditionsText = NSLocalizedString("Terms and Conditions & Privacy Policy", comment: "")
        let formattedString = NSMutableAttributedString()
        formattedString.append(NSAttributedString(string: termsAndConditionsApplyText, attributes: [NSAttributedString.Key.font: UIFont.f4sSystemFont(size: Style.smallerMediumTextSize, weight: UIFont.Weight.regular), NSAttributedString.Key.foregroundColor: UIColor(netHex: Colors.warmGrey)]))
        formattedString.append(NSAttributedString(string: termsAndConditionsText, attributes: [NSAttributedString.Key.font: UIFont.f4sSystemFont(size: Style.smallerMediumTextSize, weight: UIFont.Weight.semibold), NSAttributedString.Key.foregroundColor: UIColor(netHex: Colors.warmGrey)]))
        button.setAttributedTitle(formattedString, for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.numberOfLines = 0
        return button
    }()
    
    var applyButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.custom)
        let applyText = NSLocalizedString("Apply", comment: "")
        button.setTitle(applyText, for: UIControl.State.normal)
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var textView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = UIColor.white
        textView.font = UIFont.systemFont(ofSize: 17)
        textView.text = "Just some placeholder text for now"
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        addSubview(applyButton)
        addSubview(termsAndConditionsButton)
        addSubview(textView)
        termsAndConditionsButton.anchor(top: nil, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 20), size: CGSize(width: 0, height: 60))
        applyButton.anchor(top: nil, leading: leadingAnchor, bottom: termsAndConditionsButton.topAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 20), size: CGSize(width: 0, height: 60))
        textView.anchor(top: topAnchor, leading: leadingAnchor, bottom: applyButton.topAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
