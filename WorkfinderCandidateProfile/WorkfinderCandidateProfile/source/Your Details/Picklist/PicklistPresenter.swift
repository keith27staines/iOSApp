//
//  PicklistPresenter.swift
//  WorkfinderCandidateProfile
//
//  Created by Keith Staines on 14/04/2021.
//

import Foundation
import WorkfinderCommon
import WorkfinderServices


class PicklistPresenter: BaseAccountPresenter {

    let picklist: AccountPicklist
    
    init(coordinator: AccountCoordinator, service: AccountServiceProtocol, picklist: AccountPicklist) {
        self.picklist = picklist
        super.init(coordinator: coordinator, accountService: service)
    }
}
