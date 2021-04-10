//
//  EnableNotificationsView.swift
//  WorkfinderCandidateProfile
//
//  Created by Keith Staines on 10/04/2021.
//

import UIKit
import WorkfinderCommon
import WorkfinderUI

class EnableNotificationsCell: UITableViewCell {
    static let reuseIdentifier = "EnableNotificationsCell"
    lazy var title: UILabel = {
        let label = UILabel()
        label.text = "Enable Notifications"
        label.textAlignment = .left
        return label
    }()
    
    func configureViews() {
        contentView.addSubview(title)
        title.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 26, bottom: 0, right: 0))
        contentView.heightAnchor.constraint(equalToConstant: 47).isActive = true
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureViews()
        accessoryType = .disclosureIndicator
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
