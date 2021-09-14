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
    static var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.timeStyle = .none
        df.dateFormat = "dd MMM yyyy"
        return df
    }()
    
    static var timeFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "HH:mm"
        return df
    }()
    
    var interviewId: Int
    var cardTitle: String
    var inviteText: String
    var dateText: String
    var timeText: String
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
        let host = interview.placement?.association?.host?.fullname ?? ""
        let inviteTextEnding = host.isEmpty ? "" : " with \(host)"
        var startTimeText = ""
        var endTimeText = ""
        if let startDate = Date.dateFromRfc3339(string: interview.offerStartDate ?? "") {
            dateText = Self.dateFormatter.string(from: startDate)
            startTimeText = Self.timeFormatter.string(from: startDate)
        } else {
            dateText = ""
        }
        if let endDate = Date.dateFromRfc3339(string: interview.offerEndDate ?? "") {
            endTimeText = Self.timeFormatter.string(from: endDate)
        }
        timeText = "\(startTimeText) \(endTimeText)"
        interviewId = interview.id ?? -1
        cardTitle = "Interview"
        inviteText = "You have an upcoming interview\(inviteTextEnding)"
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
    
    func configure(with data: InterviewInviteData) {

    }

    var imageHeight: CGFloat = 46
    var buttonHeight: NSLayoutConstraint?
    var frameHeight: CGFloat = 100
    let space = WFMetrics.standardSpace
    let halfspace = WFMetrics.halfSpace
    
    private lazy var imageView: WFSelfLoadingImageView = {
        let view = WFSelfLoadingImageView()
        view.heightAnchor.constraint(equalToConstant: 46).isActive = true
        return view
    }()
    
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        var style = WFTextStyle.labelTextRegular
        style.color = UIColor(red: 0.008, green: 0.188, blue: 0.161, alpha: 1)
        label.applyStyle(style)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var button: WFButton = {
        let button = WFButton(heightClass: .larger)
        return button
    }()
    
    private lazy var mainStack: UIStackView = {
        let variableSpace = UIView()
        let stack = UIStackView(arrangedSubviews: [
                imageView,
                textLabel,
                variableSpace,
                button
            ]
        )
        stack.axis = .vertical
        stack.spacing = halfspace
        return stack
    }()
    
    private lazy var tile: UIView = {
        let view = UIView()
        view.addSubview(mainStack)
        mainStack.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: space, left: space, bottom: space, right: space))

        return view
    }()
    
    func configureViews() {
        contentView.addSubview(mainStack)
        mainStack.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor)
    }

    init(frameHeight: CGFloat, imageHeight: CGFloat, buttonHeight: CGFloat) {
        super.init(frame: CGRect.zero)
        configureViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


