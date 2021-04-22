//
//  NotificationControlsCell.swift
//  WorkfinderCandidateProfile
//
//  Created by Keith Staines on 10/04/2021.
//

import UIKit
import WorkfinderCommon
import WorkfinderUI

class NotificationControlsCell: UITableViewCell {
    
    static let reuseIdentifier = "NotificationControlsCell"
    
    private var preferences = NotificationPreferences()
    
    func configureWith(preferences: NotificationPreferences) {
        self.preferences = preferences
        applicationUpdatesSwitch.switchButton.isEnabled = preferences.isEnabled
        interviewUpdatesSwitch.switchButton.isEnabled = preferences.isEnabled
        recommendationsSwitch.switchButton.isEnabled = preferences.isEnabled
        applicationUpdatesSwitch.switchButton.isOn = preferences.allowApplicationUpdates
        interviewUpdatesSwitch.switchButton.isOn = preferences.allowInterviewUpdates
        recommendationsSwitch.switchButton.isOn = preferences.allowRecommendations

        applicationUpdatesSwitch.valueDidChange = { isAllowed in
            preferences.allowApplicationUpdates = isAllowed
        }
        interviewUpdatesSwitch.valueDidChange = { isAllowed in
            preferences.allowInterviewUpdates = isAllowed
        }
        recommendationsSwitch.valueDidChange = { isAllowed in
            preferences.allowRecommendations = isAllowed
        }
        
    }
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = UIColor.init(white: 0.56, alpha: 1)
        label.text = "Notify me when..."
        return label
    }()
    
    lazy var applicationUpdatesSwitch: LabelledSwitch = {
        let view = LabelledSwitch(text: "I have application updates", isOn: false)
        view.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return view
    }()
    
    lazy var interviewUpdatesSwitch: LabelledSwitch = {
        LabelledSwitch(text: "I have interview updates", isOn: false)
    }()
    
    lazy var recommendationsSwitch: LabelledSwitch = {
        LabelledSwitch(text: "We find employers of interest", isOn: false)
    }()
    
    lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
                label,
                applicationUpdatesSwitch,
                interviewUpdatesSwitch,
                recommendationsSwitch
            ]
        )
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 4
        return stack
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(stack)
        stack.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: 17, left: 26, bottom: 17, right: 16))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class LabelledSwitch: UIView {
    
    var valueDidChange: ((Bool) -> Void)?
    
    @objc private func onValueChanged() { valueDidChange?(switchButton.isOn) }
    
    lazy var switchButton: UISwitch = {
        let toggle = UISwitch()
        toggle.addTarget(self, action: #selector(onValueChanged), for: .valueChanged)
        toggle.setContentHuggingPriority(.required, for: .horizontal)
        return toggle
    }()
    
    private var label:UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = UIColor.init(white: 0.56, alpha: 1)
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    lazy var stack: UIStackView = {
        let spacer = UIView()
        spacer.widthAnchor.constraint(equalToConstant: 20).isActive = true
        let stack = UIStackView(arrangedSubviews: [
                label,
                spacer,
                switchButton
            ]
        )
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.alignment = .center
        stack.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return stack
    }()
    
    init(text: String, isOn: Bool) {
        super.init(frame: .zero)
        switchButton.isOn = isOn
        label.text = text
        addSubview(stack)
        stack.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
