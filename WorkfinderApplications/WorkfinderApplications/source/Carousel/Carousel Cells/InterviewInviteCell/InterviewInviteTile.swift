//
//  InterviewInviteTile.swift
//  WorkfinderApplications
//
//  Created by Keith on 22/09/2021.
//  Copyright © 2021 Workfinder. All rights reserved.
//

import UIKit
import WorkfinderUI

class InterviewInviteTile: UIView {
    
    func configure(with data: InterviewInviteTileData?, offerMessageLines: Int = 2) {
        tileTitle.text = data?.tileTitle
        inviteText.text = data?.inviteText
        dateText.text = data?.dateText
        timeText.text = data?.timeText
        hostNoteHeading.text = data?.hostNotesHeading
        offerMessage.text = data?.offerMessage?.replacingOccurrences(of: "\n", with: " ")
        button.text = data?.buttonText
        button.buttonTapped = data?.buttonAction
        waitingForLinkLabel.text = data?.waitingForLinkText
        button.isHidden = data?.isButtonHidden ?? true
        button.state = .normal
        waitingForLinkLabel.isHidden = !(data?.isButtonHidden ?? false)
        offerMessage.numberOfLines = offerMessageLines
    }
    
    var buttonHeight: NSLayoutConstraint?
    var frameHeight: CGFloat = 100
    let space = WFMetrics.standardSpace
    let halfspace = WFMetrics.halfSpace
            
    private lazy var tileTitle: UILabel = {
        let label = UILabel()
        label.applyStyle(smallHeadingStyle)
        label.numberOfLines = 1
        return label
    }()
    
    var smallHeadingStyle: WFTextStyle {
        var style = WFTextStyle.smallLabelTextBold
        style.color = WFColorPalette.gray2
        return style
    }
    
    private lazy var inviteText: UILabel = {
        let label = UILabel()
        let style = WFTextStyle.labelTextRegular
        label.applyStyle(style)
        label.numberOfLines = 0
        return label
    }()
    
    lazy var line: UIView = {
        let view = UIView()
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        view.backgroundColor = WFColorPalette.gray2
        return view
    }()
    
    lazy var topStack: UIStackView = {
        let stack = UIStackView()
        stack.addArrangedSubview(tileTitle)
        stack.addArrangedSubview(inviteText)
        stack.addArrangedSubview(line)
        stack.axis = .vertical
        stack.spacing = WFMetrics.standardSpace - 3
        return stack
    }()
    
    private lazy var dateHeading: UILabel = {
        let label = UILabel()
        label.applyStyle(smallHeadingStyle)
        label.numberOfLines = 1
        label.text = "Date"
        return label
    }()
    
    private lazy var timeHeading: UILabel = {
        let label = UILabel()
        label.applyStyle(smallHeadingStyle)
        label.numberOfLines = 1
        label.text = "Time"
        return label
    }()
    
    private lazy var dateText: UILabel = {
        let label = UILabel()
        label.applyStyle(WFTextStyle.labelTextRegular)
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var timeText: UILabel = {
        let label = UILabel()
        label.applyStyle(WFTextStyle.labelTextRegular)
        label.numberOfLines = 1
        return label
    }()
    
    lazy var dateStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.addArrangedSubview(dateHeading)
        stack.addArrangedSubview(dateText)
        stack.spacing = WFMetrics.halfSpace
        return stack
    }()

    lazy var timeStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.addArrangedSubview(timeHeading)
        stack.addArrangedSubview(timeText)
        stack.spacing = WFMetrics.halfSpace
        return stack
    }()
    
    lazy var dateTimeStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.addArrangedSubview(dateStack)
        stack.addArrangedSubview(timeStack)
        stack.distribution = .fillEqually
        return stack
    }()

    private lazy var hostNoteHeading: UILabel = {
        let label = UILabel()
        label.applyStyle(smallHeadingStyle)
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var offerMessage: UILabel = {
        let label = UILabel()
        var style = WFTextStyle.labelTextRegular
        label.applyStyle(style)
        label.numberOfLines = 2
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()
    
    lazy var hostStack: UIStackView = {
        let stack = UIStackView()
        stack.addArrangedSubview(hostNoteHeading)
        stack.addArrangedSubview(offerMessage)
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }()
    
    private lazy var buttonContainer: UIView = {
        let view = UIView()
        view.addSubview(waitingForLinkLabel)
        view.addSubview(button)
        view.heightAnchor.constraint(equalToConstant: 40).isActive = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        button.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        waitingForLinkLabel.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
        return view
    }()
    
    private lazy var button: WFButton = {
        let button = WFButton(heightClass: .larger, isCapsule: true)
        return button
    }()

    private lazy var waitingForLinkLabel: UILabel = {
        let label = UILabel()
        var style = WFTextStyle.labelTextRegular
        style.color = WFColorPalette.gray2
        label.applyStyle(style)
        label.numberOfLines = 2
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()
    
    private lazy var mainStack: UIStackView = {
        let variableSpace = UIView()
        let stack = UIStackView(arrangedSubviews: [
            topStack,
            dateTimeStack,
            hostStack,
            UIView(),
            buttonContainer
        ])
        stack.axis = .vertical
        stack.spacing = WFMetrics.standardSpace - 2
        return stack
    }()

    func configureViews() {
        let pad = WFMetrics.standardSpace
        layer.borderWidth = 1
        layer.cornerRadius = pad/2
        layer.borderColor = WFColorPalette.border.cgColor
        addSubview(mainStack)
        mainStack.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: pad, left: pad, bottom: pad, right: pad))
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
