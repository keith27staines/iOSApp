//
//  MarketingEmailCell.swift
//  WorkfinderCandidateProfile
//
//  Created by Keith Staines on 10/04/2021.
//

import UIKit
import WorkfinderCommon
import WorkfinderUI

class MarketingEmailCell: UITableViewCell {
    
    static let reuseIdentifier = "MarketingEmailCell"
    
    private var preferences = EmailPreferences()
    
    lazy var emailSwitch: LabelledSwitch = {
        LabelledSwitch(text: "Receive marketing and promotional emails from us", isOn: true)
    }()
    
    func configureWith(preferences: EmailPreferences) {
        let switchButton = emailSwitch.switchButton
        switchButton.isEnabled = preferences.isEnabled
        switchButton.isOn = preferences.allowMarketingEmails
        emailSwitch.valueDidChange = { isAllowed in
            preferences.setMarketingEmailPreference(allow: switchButton.isOn) { (optionalError) in
                switchButton.isOn = preferences.allowMarketingEmails
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(emailSwitch)
        emailSwitch.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: 17, left: 26, bottom: 17, right: 20))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
