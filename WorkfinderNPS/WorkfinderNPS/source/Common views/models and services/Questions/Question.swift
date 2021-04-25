//
//  Question.swift
//  WorkfinderNPS
//
//  Created by Keith Staines on 25/04/2021.
//

import Foundation


let allQuestions = [
    Question(text: "Communication"),
    Question(text: "Task Delegation"),
    Question(text: "Membership"),
    Question(text: "Feedback"),
    Question(text: "Hospitality"),
    Question(text: "Other"),
]


public struct Question {
    public var text: String
    public var answer: Answer = .unchecked
}

public enum Answer {
    case unchecked
    case checked(String?)
}
