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

public class WorkfinderInterviewCoordinator: CoreInjectionNavigationCoordinator {
    var newNavigationRouter: NavigationRouter?
    var rootOfNewNavigation: UIViewController?
    var parentVC: UIViewController?
    var interview: InterviewJson?
    var selectedInterviewDate: InterviewJson.InterviewDateJson?
    
    public override func start() {
        
    }
    
    lazy var overlay: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.init(white: 0, alpha: 0.5)
        return view
    }()
    
    public func startFromAcceptInviteScreen(parentVC: UIViewController, interviewId: Int) {
        self.parentVC = parentVC
        let service = InviteService(networkConfig: injected.networkConfig)
        let presenter = InterviewPresenter(service: service, coordinator: self, interviewId: interviewId)
        let rootOfNewNavigation = InterviewViewController(coordinator: self, presenter: presenter)
        let newNavigationController = UINavigationController(rootViewController: rootOfNewNavigation)
        newNavigationController.modalPresentationStyle = .overFullScreen
        addOverlayToParentView()
        newNavigationRouter = NavigationRouter(navigationController: newNavigationController)
        parentVC.present(newNavigationController, animated: true, completion: nil)
    }
    
    private func addOverlayToParentView() {
        guard let presentingView = parentVC?.view else { return }
        presentingView.addSubview(overlay)
        presentingView.bringSubviewToFront(overlay)
        overlay.frame = CGRect(x: 0, y: -1000, width: 2000, height: 2000)
        parentVC?.navigationController?.navigationBar.layer.zPosition = -1
    }
    
    private func removeOverlay() {
        overlay.removeFromSuperview()
        parentVC?.navigationController?.navigationBar.layer.zPosition = 0
    }
}

extension WorkfinderInterviewCoordinator: AcceptInviteCoordinatorProtocol {
    
    func didComplete(withChanges changes: Bool) {
        removeOverlay()
        parentCoordinator?.childCoordinatorDidFinish(self)
        if changes {
            NotificationCenter.default.post(name: .wfApplicationDataDidChange, object: nil, userInfo: nil)
        }
        parentVC?.dismiss(animated: true, completion: nil)
    }
    
//    func interviewWasAccepted(from vc: UIViewController?) {
//        switch CalendarAccess.calendarAccessStatus() {
//        case .authorized:
//            askToWriteToCalendar(from: vc)
//            return
//        case .notDetermined:
//            writeInterviewToCalendar()
//            return
//        case .denied, .restricted:
//            didComplete(with: false)
//        @unknown default:
//            parentVC?.dismiss(animated: true, completion: nil)
//        }
//    }
    
//    private func askToWriteToCalendar(from vc: UIViewController?) {
//        guard let vc = vc else { return }
//        let alert = UIAlertController(title: "Add to Calendar?", message: "Workfinder can add this interview to your calendar for your convenience", preferredStyle: .alert)
//        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
//            self?.writeInterviewToCalendar()
//        }
//        let skipAction = UIAlertAction(title: "Skip", style: .cancel) { [weak self] _ in
//            self?.parentVC?.dismiss(animated: true, completion: nil)
//        }
//        alert.addAction(skipAction)
//        alert.addAction(addAction)
//        vc.present(alert, animated: true, completion: nil)
//    }
    
//    private func writeInterviewToCalendar() {
//        let title = "Project title"
//        let description = "Interview arranged via Workfinder"
//        let start = Date()
//        let end = Date().addingTimeInterval(3600)
//        CalendarAccess.addEventToCalendar(title: title, description: description, startDate: start, endDate: end) { success, error in
//            DispatchQueue.main.async { [weak self] in
//                self?.parentVC?.dismiss(animated: true, completion: nil)
//            }
//        }
//    }
}
