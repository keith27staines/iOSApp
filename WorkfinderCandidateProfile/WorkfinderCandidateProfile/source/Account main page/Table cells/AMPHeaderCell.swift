//
//  AMPHeaderCell.swift
//  WorkfinderCandidateProfile
//
//  Created by Keith Staines on 09/04/2021.
//

import UIKit
import WorkfinderUI

class AMPHeaderCell: UITableViewCell {
    
    static let reuseIdentifier = "header"
    static let defaultImage: UIImage? = UIImage(named: "avatar")
    
    var _onTap: (() -> Void)?
    
    func configureWith(avatar: UIImage?,
                       title: String?,
                       initials: String?,
                       email: String?,
                       onTap: (() -> Void)?
    ) {
        _avatarView.image = avatar
        _title.text = title
        _subtitle.setTitle(email, for: .normal)
        _initials.text = initials
        if let onTap = onTap {
            _subtitle.addTarget(self, action: #selector(onButtonTap), for: .touchUpInside)
            _subtitle.setTitle("Register or sign in to workfinder", for: .normal)
            _subtitle.setTitleColor(WorkfinderColors.primaryColor, for: .normal)
            _onTap = onTap
        }
    }
    
    private lazy var _initials: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 33, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.shadowRadius = 1
        label.layer.shadowColor = UIColor.init(white: 0, alpha: 1).cgColor
        label.layer.shadowOpacity = 1.0
        label.layer.shadowOffset = CGSize(width: 0, height: 0)
        return label
    }()
    
    private lazy var _avatarView: UIImageView = {
        let view = UIImageView(image: AMPHeaderCell.defaultImage)
        view.heightAnchor.constraint(equalToConstant: 70).isActive = true
        view.widthAnchor.constraint(equalToConstant: 70).isActive = true
        view.layer.cornerRadius = 35
        view.layer.masksToBounds = true
        view.addSubview(_initials)
        _initials.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        _initials.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        return view
    }()
    
    private lazy var _title: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 23, weight: .regular)
        label.textColor = UIColor(red:0.15, green:0.15, blue:0.15, alpha:1)
        return label
    }()
    
    private lazy var _subtitle: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        button.setTitleColor(UIColor(red:0.56, green:0.56, blue:0.56, alpha:1), for: .normal)
        return button
    }()
    
    @objc func onButtonTap() { _onTap?() }
    
    private lazy var _textStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [_title, _subtitle])
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 0
        return stack
    }()
    
    private lazy var _mainStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [_avatarView, _textStack])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 14
        return stack
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(_mainStack)
        _mainStack.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: 12, left: 26, bottom: 12, right: 20))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
