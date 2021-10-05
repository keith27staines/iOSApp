//
//  InterviewInviteData.swift
//  WorkfinderApplications
//
//  Created by Keith on 22/09/2021.
//  Copyright © 2021 Workfinder. All rights reserved.
//

import WorkfinderUI
import WorkfinderServices

struct InterviewInviteTileData: Hashable {
    var interviewId: Int
    var tileTitle: String
    var inviteText: String
    var dateText: String
    var timeText: String
    var hostNotesHeading: String?
    var hostNotes: String?
    var offerMessage: String?
    var joinInterviewAction: (() -> Void)?
    var joinInterviewButtonText: String
    var joinInterviewButtonState: WFButton.State = .normal
    var isJoinInterviewButtonHidden: Bool { meetingLink == nil ? true : false }
    var secondaryButtonAction: (() -> Void)?
    var secondaryButtonText: String?
    var secondaryButtonState: WFButton.State = .normal
    var isSecondaryButtonHidden: Bool = true
    var waitingForLinkText: String?
    private var interviewJson: InterviewJson?
    var meetingLink: URL?
    var placementUuid: String? { interviewJson?.placement?.uuid }

    static func == (lhs: InterviewInviteTileData, rhs: InterviewInviteTileData) -> Bool {
        lhs.interviewJson == rhs.interviewJson
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(interviewJson)
    }
    
    init(interview: InterviewJson, secondaryButtonAction: (() -> Void)? = nil, secondardyButtonText: String? = nil) {
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
        joinInterviewAction = {
            if let link = URL(string: interview.meetingLink ?? "") {
                UIApplication.shared.open(link, options: [:], completionHandler: nil)
            }
        }
        joinInterviewButtonText = "Join Video Interview"
        joinInterviewButtonState = .normal
        waitingForLinkText = "We will share the meeting link with you when the host submits it to us"
        self.secondaryButtonAction = secondaryButtonAction
        self.secondaryButtonText = secondardyButtonText
        isSecondaryButtonHidden = secondaryButtonAction == nil
    }
}
