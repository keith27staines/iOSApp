//
//  RemoveAccountCell.swift
//  WorkfinderCandidateProfile
//
//  Created by Keith Staines on 10/04/2021.
//

import UIKit
import WorkfinderCommon
import WorkfinderUI

class RemoveAccountCell: UITableViewCell {
    static let reuseIdentifier = "RemoveAccountCell"
    
    var didTapRemoveAccount: (() -> Void)?
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = UIColor(red:0.56, green:0.56, blue:0.56, alpha:1)
        label.numberOfLines = 0
        label.text = "In line with GDPR regulations, it is possible for you to request removal of your account"
        return label
    }()
    
    lazy var removeButton: UIButton = {
        let button = UIButton()
        button.setTitle("Remove my account", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.setTitleColor(UIColor.red, for: .normal)
        button.setTitleColor(UIColor.lightGray, for: .disabled)
        button.addTarget(self, action: #selector(removeAccountTapped), for: .touchUpInside)
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        let w = button.widthAnchor.constraint(equalToConstant: 400)
        w.priority = .defaultHigh
        w.isActive = true
        return button
    }()
    
    @objc func removeAccountTapped() {
        didTapRemoveAccount?()
    }
    
    lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
                self.label,
            self.removeButton
            ]
        )
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 8
        return stack
    }()
    
    func configureWith(enabled: Bool, didTapRemoveAccount: @escaping () -> Void) {
        removeButton.isEnabled = enabled
        self.didTapRemoveAccount = didTapRemoveAccount
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(stack)
        stack.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: 18, left: 26, bottom: 0, right: 20))
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
