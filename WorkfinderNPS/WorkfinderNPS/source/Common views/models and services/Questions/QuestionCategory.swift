//
//  QuestionCategory.swift
//  WorkfinderNPS
//
//  Created by Keith Staines on 25/04/2021.
//

import Foundation

public class QuestionCategory {
    public var title: String = ""
    public var summary: String = ""
    public var questions = [Question]()
    public init(title: String, summary: String, questions: [Question]) {
        self.title = title
        self.summary = summary
        self.questions = questions
    }
}
