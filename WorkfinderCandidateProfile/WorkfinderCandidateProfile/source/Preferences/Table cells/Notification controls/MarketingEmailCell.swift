//
//  MarketingEmailCell.swift
//  WorkfinderCandidateProfile
//
//  Created by Keith Staines on 10/04/2021.
//

import UIKit
import WorkfinderCommon
import WorkfinderUI

struct EmailPreferences {
    var isDirty: Bool = false
    var isEnabled: Bool = true
    var allowMarketingEmails: Bool = true { didSet { isDirty = true } }
}

class MarketingEmailCell: UITableViewCell {
    
    static let reuseIdentifier = "MarketingEmailCell"
    
    private var preferences = EmailPreferences()
    
    lazy var emailSwitch: LabelledSwitch = {
        LabelledSwitch(text: "Receive marketing and promotional emails from us", isOn: true)
    }()
    
    func configureWith(preferences: EmailPreferences) {
        emailSwitch.switchButton.isEnabled = preferences.isEnabled
        emailSwitch.switchButton.isOn = preferences.allowMarketingEmails
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        textLabel?.text = "MarketingEmailCell"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
