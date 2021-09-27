//
//  InterviewPresenting.swift
//  WorkfinderInterviews
//
//  Created by Keith on 18/09/2021.
//
import WorkfinderUI

protocol InterviewPresenting {
    var presenter: InterviewPresenter? { get set }
    var messageHandler: UserMessageHandler? { get set }
    func updateFromPresenter()
}
