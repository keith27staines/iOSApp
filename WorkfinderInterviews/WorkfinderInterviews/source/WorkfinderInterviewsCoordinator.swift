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
import WorkfinderServices

public class WorkfinderInterviewsCoordinator: CoreInjectionNavigationCoordinator {
    
    var newNavigationRouter: NavigationRouter?
    var rootOfNewNavigation: UIViewController?
    var parentVC: UIViewController?
    var interview: InterviewJson?
    var selectedInterviewDate: InterviewJson.InterviewDateJson?
    
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
    func interviewWasAccepted(from vc: UIViewController?) {
        switch CalendarAccess.calendarAccessStatus() {
        case .authorized:
            askToWriteToCalendar(from: vc)
            return
        case .notDetermined:
            writeInterviewToCalendar()
            return
        case .denied:
            parentVC?.dismiss(animated: true, completion: nil)
        case .restricted:
            parentVC?.dismiss(animated: true, completion: nil)
        @unknown default:
            parentVC?.dismiss(animated: true, completion: nil)
        }
    }
    
    private func askToWriteToCalendar(from vc: UIViewController?) {
        guard let vc = vc else { return }
        let alert = UIAlertController(title: "Add to Calendar?", message: "Workfinder can add this interview to your calendar for your convenience", preferredStyle: .alert)
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            self?.writeInterviewToCalendar()
        }
        let skipAction = UIAlertAction(title: "Skip", style: .cancel) { [weak self] _ in
            self?.parentVC?.dismiss(animated: true, completion: nil)
        }
        alert.addAction(skipAction)
        alert.addAction(addAction)
        vc.present(alert, animated: true, completion: nil)
    }
    
    private func writeInterviewToCalendar() {
        let title = "Project title"
        let description = "Interview arranged via Workfinder"
        let start = Date()
        let end = Date().addingTimeInterval(3600)
        CalendarAccess.addEventToCalendar(title: title, description: description, startDate: start, endDate: end) { success, error in
            DispatchQueue.main.async { [weak self] in
                self?.parentVC?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func showDateSelector() {
        let dateSelectorPresenter = DateSelectorPresenter(coordinator: self)
        let vc = DateSelectorViewController(presenter: dateSelectorPresenter)
        newNavigationRouter?.push(viewController: vc, animated: true)
    }
    
    func showProjectDetails() {
        let service = InviteService(networkConfig: injected.networkConfig)
        let presenter = ProjectPresenter(coordinator: self, service: service)
        let vc = ProjectViewController(coordinator: self, presenter: presenter)
        newNavigationRouter?.push(viewController: vc, animated: true)
    }
    
    func acceptViewControllerDidCancel(_ vc: AcceptInviteViewController) {
        navigationRouter.pop(animated: true)
        parentCoordinator?.childCoordinatorDidFinish(self)
        parentVC?.dismiss(animated: true, completion: nil)
    }
}
