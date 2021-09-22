//
//  InterviewInviteData.swift
//  WorkfinderApplications
//
//  Created by Keith on 22/09/2021.
//  Copyright © 2021 Workfinder. All rights reserved.
//

import WorkfinderUI
import WorkfinderServices

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
