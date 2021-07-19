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
    
    var newNavigationRouter: NavigationRouter?
    var rootOfNewNavigation: UIViewController?
    var parentVC: UIViewController?
    var interviewInvite: InterviewInvite?
    
    public override func start() {
        
    }
    
    public func startFromAcceptInviteScreen(parentVC: UIViewController, inviteId: String) {
        self.parentVC = parentVC
        let service = InviteService(networkConfig: injected.networkConfig)
        let presenter = AcceptInvitePresenter(service: service, coordinator: self, interviewId: inviteId)
        let rootOfNewNavigation = AcceptInviteViewController(coordinator: self, presenter: presenter)
        rootOfNewNavigation.modalPresentationStyle = .overFullScreen
        let newNavigationController = UINavigationController(rootViewController: rootOfNewNavigation)
        newNavigationController.modalPresentationStyle = .overFullScreen
        newNavigationRouter = NavigationRouter(navigationController: newNavigationController)
        parentVC.present(newNavigationController, animated: true, completion: nil)
    }
}

extension WorkfinderInterviewsCoordinator: AcceptInviteCoordinatorProtocol {
    func interviewWasAccepted() {
        parentVC?.dismiss(animated: true, completion: nil)
    }
    
    func showDateSelector() {
        guard let dates = interviewInvite?.possibleDates else { return }
        let dateSelectorPresenter = DateSelectorPresenter(dates: dates)
        let vc = DateSelectorViewController(presenter: dateSelectorPresenter)
        newNavigationRouter?.push(viewController: vc, animated: true)
    }
    
    func showProjectDetails() {
        print("Show project details")
    }
    
    func acceptViewControllerDidCancel(_ vc: AcceptInviteViewController) {
        navigationRouter.pop(animated: true)
        parentCoordinator?.childCoordinatorDidFinish(self)
        parentVC?.dismiss(animated: true, completion: nil)
    }
}
