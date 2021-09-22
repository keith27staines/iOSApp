//
//  InterviewInviteCell.swift
//  WorkfinderApplications
//
//  Created by Keith on 13/09/2021.
//  Copyright © 2021 Workfinder. All rights reserved.
//

import Foundation


import UIKit
import WorkfinderServices
import WorkfinderUI

struct InterviewInviteData {
    var interviewId: Int
    var tileTitle: String
    var inviteText: String
    var dateText: String
    var timeText: String
    var hostNotesHeading: String?
    var hostNotes: String?
    var offerMessage: String?
    var buttonAction: (() -> Void)?
    var buttonText: String
    var buttonState: WFButton.State = .normal
    var isButtonHidden: Bool { meetingLink == nil ? true : false }
    var waitingForLinkText: String?
    private var interviewJson: InterviewJson?
    var meetingLink: URL?
    
    init(interview: InterviewJson) {
        interviewJson = interview
        let hostFirstName = interview.placement?.association?.host?.fullname?.split(separator: " ").first ?? "The host"
        let inviteTextEnding = hostFirstName.isEmpty ? "" : " with \(hostFirstName)"
        interviewId = interview.id ?? -1
        tileTitle = "Interview"
        inviteText = "You have an upcoming interview\(inviteTextEnding)"
        dateText = interview.selectedInterviewDate?.localDateString ?? ""
        timeText = interview.selectedInterviewDate?.localStartToEndTimeString ?? ""
        hostNotesHeading = "\(hostFirstName)'s notes"
        hostNotes = interview.additionalOfferNote
        offerMessage = interview.offerMessage
        meetingLink = URL(string: interview.meetingLink ?? "")
        buttonAction = {
            if let link = URL(string: interview.meetingLink ?? "") {
                UIApplication.shared.open(link, options: [:], completionHandler: nil)
            }
        }
        buttonText = "Join Video Interview"
        buttonState = .normal
        waitingForLinkText = "We will share the meeting link with you when the host submits it to us"
    }
}

class InterviewInviteCell: UICollectionViewCell, CarouselCellProtocol {

    typealias CellData = InterviewInviteData
    static var identifier = "InterviewInviteCell"
    private var _size = CGSize.zero
    
    func configure(with data: InterviewInviteData, size: CGSize) {
        _size = size
        tileTitle.text = data.tileTitle
        inviteText.text = data.inviteText
        dateText.text = data.dateText
        timeText.text = data.timeText
        hostNoteHeading.text = data.hostNotesHeading
        offerMessage.text = data.offerMessage?.replacingOccurrences(of: "\n", with: " ")
        button.text = data.buttonText
        waitingForLinkLabel.text = data.waitingForLinkText
        button.isHidden = data.isButtonHidden
        waitingForLinkLabel.isHidden = !data.isButtonHidden
    }

    var buttonHeight: NSLayoutConstraint?
    var frameHeight: CGFloat = 100
    let space = WFMetrics.standardSpace
    let halfspace = WFMetrics.halfSpace
        
    override var intrinsicContentSize: CGSize {
        _size
    }
    
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
        var style = WFTextStyle.labelTextRegular
        style.color = WFColorPalette.gray2
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
        stack.spacing = WFMetrics.standardSpace
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
        style.color = WFColorPalette.gray2
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
    
    lazy var buttonStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.addArrangedSubview(button)
        stack.addArrangedSubview(waitingForLinkLabel)
        return stack
    }()
    
    private lazy var buttonContainer: UIView = {
        let view = UIView()
        view.addSubview(waitingForLinkLabel)
        view.addSubview(button)
        view.heightAnchor.constraint(equalToConstant: 40).isActive = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        waitingForLinkLabel.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
        return view
    }()
    
    private lazy var button: WFButton = {
        let button = WFButton(heightClass: .larger)
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
            buttonStack
        ])
        stack.axis = .vertical
        stack.spacing = WFMetrics.standardSpace - 2
        return stack
    }()
    
    private lazy var tile: UIView = {
        let view = UIView()
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 8
        view.layer.borderColor = WFColorPalette.grayBorder.cgColor
        view.addSubview(mainStack)
        mainStack.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: space, left: space, bottom: space, right: space))
        return view
    }()
    
    func configureViews() {
        contentView.addSubview(tile)
        tile.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


