//
//  ProjectPresenter.swift
//  WorkfinderInterviews
//
//  Created by Keith on 20/07/2021.
//

import Foundation
import WorkfinderServices

class ProjectPresenter {
    
    weak var coordinator: AcceptInviteCoordinatorProtocol?
    let service: InviteService
    
    init(coordinator: AcceptInviteCoordinatorProtocol, service: InviteService) {
        self.coordinator = coordinator
        self.service = service
    }
    
    
    func load(completion: (Error?) -> Void) {
        completion(nil)
    }
}
