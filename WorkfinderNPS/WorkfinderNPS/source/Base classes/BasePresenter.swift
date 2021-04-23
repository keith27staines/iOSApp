//
//  BasePresenter.swift
//  WorkfinderNPS
//
//  Created by Keith on 23/04/2021.
//

import Foundation


class BasePresenter {
    
    weak var coordinator: WorkfinderNPSCoordinator?
    var service: NPSServiceProtocol
    weak var viewController: BaseViewController?
    
    func onViewDidLoad(vc: BaseViewController) {
        self.viewController = vc
    }
    
    init(coordinator: WorkfinderNPSCoordinator, service: NPSServiceProtocol) {
        self.coordinator = coordinator
        self.service = service
    }
    
}
