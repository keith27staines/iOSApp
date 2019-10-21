//
//  PersonBioView.swift
//  F4SPrototypes
//
//  Created by Keith Dev on 24/01/2019.
//  Copyright © 2019 Keith Staines. All rights reserved.
//

import UIKit
import WorkfinderCommon

class PersonBioView: UIView {
    
    private lazy var linkedInButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("linkedIn profile", for: .normal)
        button.setImage(UIImage(named: "ui-linkedin-icon")!, for: .normal)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
        button.addTarget(self, action: #selector(linkedInTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var bioText: UITextView = {
        let view = UITextView()
        view.font = UIFont.systemFont(ofSize: UIFont.systemFontSize, weight: .light)
        return view
    }()
    
    var showLinkedIn: ((F4SHost)->())?
    
    @objc func linkedInTapped() {
        guard let person = personData else { return }
        showLinkedIn?(person)
    }
    
    var personData: F4SHost? {
        willSet {
            guard newValue?.uuid != personData?.uuid else { return }
            bioText.text = ""
            linkedInButton.isHidden = newValue?.profileUrl == nil || newValue?.profileUrl == "" ? false : true
            UIView.animate(withDuration: 1) {
                self.alpha = newValue == nil ? 0.0 : 1.0
                self.layoutIfNeeded()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(linkedInButton)
        addSubview(bioText)
        bioText.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor)
        linkedInButton.anchor(top: bioText.bottomAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 8, left: 0, bottom: 4, right: 0))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

