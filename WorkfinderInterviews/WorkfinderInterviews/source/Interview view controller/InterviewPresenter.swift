//
//  AcceptInvitePresenter.swift
//  WorkfinderInterviews
//
//  Created by Keith on 14/07/2021.
//

import UIKit
import WorkfinderCommon
import WorkfinderServices

class InterviewPresenter {
    
    private let service: InviteService
    private let coordinator: AcceptInviteCoordinatorProtocol
    let interviewId: Int
    var interview: InterviewJson? { coordinator.interview }
    weak var interviewViewController: InterviewViewController?
    var dateSelectorDatasource: DateSelectorDatasource?
    
    var interviewDateSelectionDidChange: (() -> Void)?
    
    private var hostFirstName: String {
        guard let first = (interview?.placement?.association?.host?.fullname ?? "").first else { return "" }
        return String(first)
    }
    
    private var companyName: String {
        interview?.placement?.association?.location?.company?.name ?? ""
    }
    
    var isCancelPermitted: Bool {
        switch contentState {
        case .dateSelecting:
            return true
        default:
            return false
        }
    }
    
    var title: String {
        switch contentState {
        case .dateSelecting:
            return "Video Interview with \(hostNameOrTheHost) from \(companyName)"
        case .accepted:
            return "You have accepted the interview with \(hostNameOrTheHost) from \(companyName)"
        case .declining:
            return "Are you sure you want to decline this interview?"
        case .declined:
            return "You have declined the interview with \(hostNameOrTheHost) from \(companyName)"
        }
    }
    
    var hostNameOrTheHost: String {
        return hostFirstName.isEmpty ? "the host" : hostFirstName
    }
        
    var introText: String {
        switch contentState {
        case .dateSelecting:
            return "Select a time below and accept the interview invite! All times are shown in your local time."
        case .declined:
            return "Thank you for responding. We will let \(hostNameOrTheHost) know your decision."
        case .accepted:
            return "We will send the meeting details to you once \(hostNameOrTheHost) creates them."
        case .declining:
            return "Your application will not be progressed if you decline this interview."
        }
        
    }
    
    var hostNoteHeader: String {
        hostFirstName.isEmpty ? "Your host's notes" : "\(hostFirstName)'s notes"
    }
    
    var hostNoteBody: String {
        interview?.additionalOfferNote ?? ""
    }
    
    var primaryButtonEnabledText: String {
        let finishActionText = "Close"
        switch contentState {
        case .accepted, .declined: return finishActionText
        case .dateSelecting: return "Accept"
        case .declining: return "I Don't Want to Decline"
        }
    }
    
    var primaryButtonDisabledText: String {
        switch contentState {
        case .dateSelecting: return "Please Select a Time"
        default: return ""
        }
    }

    var isprimaryButtonEnabled: Bool {
        switch contentState {
        case .dateSelecting: return dateSelectorDatasource?.selectedInterviewDate == nil ? false : true
        default: return true
        }
    }
    
    var isSecondaryButtonHidden: Bool {
        switch contentState {
        case .accepted, .declined: return true
        case .dateSelecting, .declining: return false
        }
    }
    
    var secondaryButtonEnabledText: String {
        switch contentState {
        case .dateSelecting: return "Decline"
        case .declining: return "Decline This Interview"
        default: return ""
        }
    }
    
    init(service: InviteService, coordinator: AcceptInviteCoordinatorProtocol, interviewId: Int) {
        self.service = service
        self.coordinator = coordinator
        self.interviewId = interviewId
        self.contentState = .dateSelecting
    }
    
    enum ContentState {
        case dateSelecting
        case accepted
        case declining
        case declined
    }
    
    var contentState: ContentState {
        didSet {
            interviewViewController?.setContentState()
        }
    }
     
    func onViewDidLoad(_ vc: InterviewViewController) {
        self.interviewViewController = vc
    }
    
    func load(completion: @escaping (Error?) -> Void) {
        guard interview == nil else {
            completion(nil)
            return
        }
        service.loadInterview(id: interviewId) { result in
            switch result {
            case .success(let interview):
                self.coordinator.interview = interview
                self.dateSelectorDatasource = DateSelectorDatasource(interview: interview) { [weak self] in
                    self?.interviewDateSelectionDidChange?()
                }
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    func onDidTapPrimaryButton(completion: @escaping (Error?) -> Void) {
        switch contentState {
        case .accepted, .declined:
            coordinator.didComplete(withChanges: true)
        case .dateSelecting:
            acceptInterview(completion: completion)
        case .declining:
            declineInterview(completion: completion)
        }
    }
    
    func onDidTapSecondaryButton(completion: @escaping (Error?) -> Void) {
        switch contentState {
        case .dateSelecting:
            contentState = .declining
            completion(nil)
        case .declining:
            declineInterview(completion: completion)
        default: break
        }
    }
    
    func acceptInterview(completion: @escaping (Error?) -> Void) {
        guard let interviewDate = dateSelectorDatasource?.selectedInterviewDate else { return }
        service.accept(interviewDate) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                completion(error)
                return
            }
            self.contentState = .accepted
            completion(nil)
        }
    }
    
    func declineInterview(completion: @escaping (Error?) -> Void) {
        guard let uuid = interview?.uuid else { return }
        service.declineInterview(uuid: uuid) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(_):
                self.contentState = .declined
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
}
