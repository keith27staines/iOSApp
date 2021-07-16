//
//  WorkfinderInterviewsCoordinator.swift
//  WorkfinderInterviews
//
//  Created by Keith on 14/07/2021.
//

import Foundation
import WorkfinderCommon
import WorkfinderUI
import WorkfinderCoordinators

public class WorkfinderInterviewsCoordinator: CoreInjectionNavigationCoordinator {
    
    
    public override func start() {
        //
    }
    
    public func showAcceptInviteScreen(id: String) {
        let service = InviteService(networkConfig: injected.networkConfig)
        let presenter = AcceptInvitePresenter(service: service, coordinator: self)
        let vc = AcceptInviteViewController(coordinator: self, presenter: presenter)
        navigationRouter.push(viewController: vc, animated: true)
    }
}

extension WorkfinderInterviewsCoordinator: AcceptInviteCoordinatorProtocol {
    func acceptViewControllerDidAccept(_ vc: AcceptInviteViewController) {
        
    }
    
    func acceptViewControllerDidRequestAlternateDate(_ vc: AcceptInviteViewController) {
        
    }
    
    func acceptViewControllerDidCancel(_ vc: AcceptInviteViewController) {
        navigationRouter.pop(animated: true)
        parentCoordinator?.childCoordinatorDidFinish(self)
    }
}
