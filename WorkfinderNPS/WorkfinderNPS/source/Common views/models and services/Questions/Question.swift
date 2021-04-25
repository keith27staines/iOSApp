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


public class Question {
    public var text: String
    public var answer: Answer = .unchecked(nil)
    public func toggleAnswer() {
        switch answer {
        case .checked(let text): answer = .unchecked(text)
        case .unchecked(let text): answer = .checked(text)
        }
    }
    public init(text: String) {
        self.text = text
    }
}

public enum Answer {
    case unchecked(String?)
    case checked(String?)
}
