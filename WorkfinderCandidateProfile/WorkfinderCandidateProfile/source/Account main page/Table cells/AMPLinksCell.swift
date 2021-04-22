//
//  AMPLinksCell.swift
//  WorkfinderCandidateProfile
//
//  Created by Keith Staines on 09/04/2021.
//

import UIKit
import WorkfinderCommon

class AMPLinksCell: UITableViewCell {
    
    static let reuseIdentifier = "links"
    var _contentType: WorkfinderContentType?
    
    func configureWith(contentType: WorkfinderContentType) {
        _contentType = contentType
        _title.text = _contentType?.title
    }
    
    private lazy var _title: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = UIColor(red:0.43, green:0.43, blue:0.43, alpha:1)
        return label
    }()
    
    private lazy var _mainStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [_title])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 14
        return stack
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(_mainStack)
        _mainStack.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: 12, left: 26, bottom: 12, right: 20))
        accessoryType = .disclosureIndicator
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
