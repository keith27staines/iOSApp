//
//  AcceptInvitePresenter.swift
//  WorkfinderInterviews
//
//  Created by Keith on 14/07/2021.
//

import Foundation


protocol AcceptInviteCoordinatorProtocol: AnyObject {
    func acceptViewControllerDidCancel(_ vc: AcceptInviteViewController)
    func interviewWasAccepted()
    func showDateSelector()
    func showProjectDetails()
}

class AcceptInvitePresenter {
    
    private let service: InviteService
    private let coordinator: AcceptInviteCoordinatorProtocol
    let interviewId: String
    var invite: InterviewInvite?
    
    init(service: InviteService, coordinator: AcceptInviteCoordinatorProtocol, interviewId: String) {
        self.service = service
        self.coordinator = coordinator
        self.interviewId =  interviewId
    }
    
    func load(completion: @escaping (Error?) -> Void) {
        service.loadInvite(id: interviewId) { result in
            switch result {
            case .success(let invite):
                self.invite = invite
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        
        }
    }
    
    func onDidTapAccept(completion: @escaping (Error?) -> Void) {
        guard let invite = invite else { return }
        service.acceptInvite(invite) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                completion(error)
                return
            }
            self.coordinator.interviewWasAccepted()
        }
    }
    
    func didTapChooseDifferentDate(completion: @escaping (Error?) -> Void) {
        coordinator.showDateSelector()
    }
    
    
    
}
