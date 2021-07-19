//
//  AcceptInvitePresenter.swift
//  WorkfinderInterviews
//
//  Created by Keith on 14/07/2021.
//

import UIKit

protocol AcceptInviteCoordinatorProtocol: AnyObject {
    var interviewInvite: InterviewInvite? { get set }
    func acceptViewControllerDidCancel(_ vc: AcceptInviteViewController)
    func interviewWasAccepted(from vc: UIViewController?)
    func showDateSelector()
    func showProjectDetails()
}

class AcceptInvitePresenter {
    
    private let service: InviteService
    private let coordinator: AcceptInviteCoordinatorProtocol
    let interviewId: String
    var invite: InterviewInvite? { coordinator.interviewInvite }
    weak var viewController: UIViewController?
    
    init(service: InviteService, coordinator: AcceptInviteCoordinatorProtocol, interviewId: String) {
        self.service = service
        self.coordinator = coordinator
        self.interviewId =  interviewId
    }
    
    func onViewDidLoad(_ vc: UIViewController) {
        self.viewController = vc
    }
    
    func load(completion: @escaping (Error?) -> Void) {
        guard invite == nil else {
            completion(nil)
            return
        }
        service.loadInvite(id: interviewId) { result in
            switch result {
            case .success(let invite):
                self.coordinator.interviewInvite = invite
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    var dateString: String? {
        invite?.selectedDate
    }
    
    func onDidTapAccept(completion: @escaping (Error?) -> Void) {
        guard let invite = invite else { return }
        service.acceptInvite(invite) { [weak self] error in
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
