//
//  AcceptInviteCoordinatorProtocol.swift
//  WorkfinderInterviews
//
//  Created by Keith on 07/09/2021.
//

import UIKit
import WorkfinderServices

protocol AcceptInviteCoordinatorProtocol: AnyObject {
    var interview: InterviewJson? { get set }
    var selectedInterviewDate: InterviewJson.InterviewDateJson? { get set }
    func acceptViewControllerDidCancel(_ vc: AcceptInviteViewController)
    func interviewWasAccepted(from vc: UIViewController?)
    func showDateSelector()
    func showProjectDetails()
}
