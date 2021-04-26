//
//  Question.swift
//  WorkfinderNPS
//
//  Created by Keith Staines on 25/04/2021.
//

import Foundation


let allQuestions = [
    Question(questionText: "Communication"),
    Question(questionText: "Task Delegation"),
    Question(questionText: "Membership"),
    Question(questionText: "Feedback"),
    Question(questionText: "Hospitality"),
    Question(questionText: "Other"),
]

public class Question {
    public var answerPermitsText: Bool
    public var questionText: String
    public var answer: Answer

    public func toggleAnswer() {
        answer.isChecked.toggle()
    }

    public init(questionText: String, answerPermitsText: Bool = false) {
        self.questionText = questionText
        self.answerPermitsText = answerPermitsText
        self.answer = Answer(isChecked: false, answerText: nil)
    }
}

public struct Answer {
    var isChecked: Bool = false
    var answerText: String? = nil
}
