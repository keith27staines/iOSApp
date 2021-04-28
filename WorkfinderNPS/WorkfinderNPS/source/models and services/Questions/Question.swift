//
//  Question.swift
//  WorkfinderNPS
//
//  Created by Keith Staines on 25/04/2021.
//

import Foundation

public class Question {
    public enum QuestionType {
        case basic
        case other
    }

    public var questionText: String
    public var answer: Answer
    public var type: QuestionType
    public var answerPermitsText: Bool {
        switch type {
        case .other: return true
        default: return false
        }
    }

    public func toggleAnswer() {
        answer.isChecked.toggle()
    }

    public init(id: Int, questionText: String) {
        self.type = questionText.lowercased() == "other" ? .other : .basic
        self.questionText = questionText
        self.answer = Answer(isChecked: false, answerText: nil)
    }
    
    convenience init(reason: ReasonJson) {
        self.init(id: reason.id, questionText: reason.text)
    }
}

public struct Answer {
    var isChecked: Bool = false
    var answerText: String? = nil
}
