//
//  NotificationControlsCell.swift
//  WorkfinderCandidateProfile
//
//  Created by Keith Staines on 10/04/2021.
//

import UIKit
import WorkfinderCommon
import WorkfinderUI

struct NotificationPreferences {
    var isDirty: Bool = false
    var isEnabled: Bool = false
    var allowApplicationUpdates: Bool = true { didSet { isDirty = true } }
    var allowInterviewUpdates: Bool = true  { didSet { isDirty = true } }
    var allowRecommendations: Bool = true  { didSet { isDirty = true } }
}

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
    }
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.text = "Notify me when"
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
        LabelledSwitch(text: "We have employers of interest", isOn: false)
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
        stack.spacing = 8
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
        toggle.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return toggle
    }()
    
    private var label:UILabel = {
        let label = UILabel()
        return label
    }()
    
    lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
                label,
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
