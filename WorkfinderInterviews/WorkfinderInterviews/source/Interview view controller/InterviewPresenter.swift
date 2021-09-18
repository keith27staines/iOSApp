//
//  AcceptInvitePresenter.swift
//  WorkfinderInterviews
//
//  Created by Keith on 14/07/2021.
//

import UIKit
import WorkfinderServices

class InterviewPresenter {
    
    private let service: InviteService
    private let coordinator: AcceptInviteCoordinatorProtocol
    let interviewId: Int
    var interview: InterviewJson? { coordinator.interview }
    weak var viewController: UIViewController?
    
    init(service: InviteService, coordinator: AcceptInviteCoordinatorProtocol, interviewId: Int) {
        self.service = service
        self.coordinator = coordinator
        self.interviewId =  interviewId
        self.contentState = .dateSelecting
    }
    
    enum ContentState {
        case dateSelecting
        case accepted
        case declining
        case declined
    }
    
    var contentState: ContentState 
    
    func onViewDidLoad(_ vc: UIViewController) {
        self.viewController = vc
    }
    
    func load(completion: @escaping (Error?) -> Void) {
        guard interview == nil else {
            completion(nil)
            return
        }
        service.loadInterview(id: interviewId) { result in
            switch result {
            case .success(let invite):
                self.coordinator.interview = invite
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    private var _selectedInterviewDateId: Int?
    
    private var selectedInterviewDate: InterviewJson.InterviewDateJson? {
        get {
            interview?.interviewDates?.first { $0.id == _selectedInterviewDateId }
        }
        set {
            _selectedInterviewDateId = newValue?.id
        }
    }
    
    var dateString: String? {
        guard let dateString = selectedInterviewDate?.dateTime, let date = Date.dateFromRfc3339(string: dateString)
        else { return nil }
        let df = DateFormatter()
        df.timeStyle = .none
        df.dateStyle = .medium
        return df.string(from: date)
    }
    
    var timeString: String? { selectedInterviewDate?.timeString }
    
    
    func onDidTapAccept(completion: @escaping (Error?) -> Void) {
        guard let interviewDate = selectedInterviewDate else { return }
        service.accept(interviewDate) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                completion(error)
                return
            }
            self.coordinator.interviewWasAccepted(from: self.viewController)
        }
    }
    
    func didTapChooseDifferentDate(completion: @escaping (Error?) -> Void) {
        coordinator.showDateSelector()
    }

}
