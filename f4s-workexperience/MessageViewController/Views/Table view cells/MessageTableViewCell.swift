//
//  MessageTableViewCell.swift
//
//  Created by Keith Staines on 24/11/2018.
//  Copyright © 2018 Keith Staines. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {
    
    fileprivate var label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    fileprivate lazy var labelContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.addSubview(label)
        label.anchor(
            top: view.topAnchor,
            leading: view.leadingAnchor,
            bottom: view.bottomAnchor,
            trailing: view.trailingAnchor,
            padding: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8),
            size: CGSize.zero)

        return view
    }()
    
    func configureWith(_ message: MessageProtocol) {
        label.text = message.text
    }
    
    func configureWith(backgroundColor: UIColor, textColor: UIColor) {
        labelContainer.backgroundColor = backgroundColor
        label.textColor = textColor
    }
    
    fileprivate override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        let contentView = self.contentView
        contentView.addSubview(labelContainer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class IncomingMessageTableViewCell: MessageTableViewCell {
    static var reuseIdentifier: String = "incoming"
    public override var reuseIdentifier: String? { return IncomingMessageTableViewCell.reuseIdentifier }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        labelContainer.anchor(
            top: contentView.topAnchor,
            leading: contentView.leadingAnchor,
            bottom: contentView.bottomAnchor,
            trailing: nil,
            padding: UIEdgeInsets(top: 20, left: 4, bottom: 0, right: 0),
            size: CGSize.zero)
        labelContainer.widthAnchor.constraint(
            lessThanOrEqualTo: contentView.widthAnchor,
            multiplier: 0.66)
            .isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class OutgoingMessageTableViewCell: MessageTableViewCell {
    
    static var reuseIdentifier: String = "outgoing"
    public override var reuseIdentifier: String? { return OutgoingMessageTableViewCell.reuseIdentifier }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        labelContainer.anchor(
            top: contentView.topAnchor,
            leading: nil, bottom: contentView.bottomAnchor,
            trailing: contentView.trailingAnchor,
            padding: UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 4),
            size: CGSize.zero)
        labelContainer.widthAnchor.constraint(
            lessThanOrEqualTo: contentView.widthAnchor,
            multiplier: 0.66)
            .isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
