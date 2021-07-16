//
//  AcceptInvitePresenter.swift
//  WorkfinderInterviews
//
//  Created by Keith on 14/07/2021.
//

import Foundation


protocol AcceptInviteCoordinatorProtocol: AnyObject {
    func acceptViewControllerDidCancel(_ vc: AcceptInviteViewController)
    func acceptViewControllerDidAccept(_ vc: AcceptInviteViewController)
    func acceptViewControllerDidRequestAlternateDate(_ vc: AcceptInviteViewController)
}

class AcceptInvitePresenter {
    
    private let service: InviteService
    private let coordinator: AcceptInviteCoordinatorProtocol
    
    init(service: InviteService, coordinator: AcceptInviteCoordinatorProtocol) {
        self.service = service
        self.coordinator = coordinator
    }
    
    func load(completion: @escaping (Error?) -> Void) {
        completion(nil)
    }
    
    
}
