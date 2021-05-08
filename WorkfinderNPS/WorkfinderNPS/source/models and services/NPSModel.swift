//
//  NPS.swift
//  WorkfinderNPS
//
//  Created by Keith on 23/04/2021.
//

import Foundation

public class NPSModel {
    public var accessToken: String?
    public var reviewUuid: String?
    public var score: Int?
    public var category: QuestionCategory?
    public var hostName: String?
    public var projectName: String?
    public var companyName: String?
    public var feedbackText: String?
    public var anonymous: Bool
    public var otherReasonText: String? {
        category?.questions.first(where: { question in
            question.questionText.lowercased() == "other"
        })?.answer.answerText
    }
    public private (set) var downloadedReasonIds: [Int] = []
    
    var categories: [QuestionCategory]?
    
    var allQuestions = [Question]() {
        didSet {
            categories?.forEach({ category in
                category.questions = allQuestions
            })
        }
    }
    
    func reloadFrom(reviewJson: GetReviewJson, allQuestions: [Question]) {
        self.allQuestions = allQuestions
        hostName = reviewJson.placement.hostFullname
        projectName = reviewJson.placement.projectName
        companyName = reviewJson.placement.companyName
        feedbackText = reviewJson.feedback
        anonymous = reviewJson.anonymous
        self.buildCategories(hostName: hostName ?? "", allQuestions: allQuestions)
        setScore(reviewJson.score ?? score)
        synchronizeSelections(with: reviewJson.reasons, otherReasonText: reviewJson.otherReason)
    }
    
    private func synchronizeSelections(with reasons: [Int], otherReasonText: String?) {
        clearAllSelections()
        allQuestions.forEach { question in
            let questionId = question.serverId
            let isQuestionSelected = reasons.contains(questionId)
            if isQuestionSelected {
                let isOther = question.questionText.lowercased() == "other"
                let answerText: String? = isOther ? otherReasonText : nil
                question.answer = .init(isChecked: true, answerText: answerText)
            }
        }
    }
    
    private func clearAllSelections() {
        allQuestions.forEach { question in
            question.answer = .init(isChecked: false, answerText: nil)
        }
    }
    
    private func buildCategories(hostName: String, allQuestions: [Question]) {
        var categories = [QuestionCategory]()
        let bad = QuestionCategory(
            title: "What went wrong?",
            summary: "\(hostName) was not recommended",
            questions: allQuestions
        )
        
        let ok = QuestionCategory(
            title: "What could have been better",
            summary: "\(hostName) was fine but there are some areas of improvement",
            questions: allQuestions
        )
        
        let good = QuestionCategory(
            title: "What went well?",
            summary: "\(hostName) was great in your placement experience",
            questions: allQuestions
        )
        
        categories.append(bad)
        categories.append(ok)
        categories.append(good)

        self.categories = categories
    }

    func setScore(_ score: Int?) {
        let score = Score(rawValue: score ?? -1)
        setScore(score)
    }
    
    func setScore(_ score: Score?) {
        self.score = score?.rawValue
        setCategoryForScore(score)
    }
    
    private func setCategoryForScore(_ score: Score?) {
        guard let scoreValue = score?.rawValue, let categories = categories else { return }
        switch scoreValue {
        case 0..<7: category = categories[0]
        case 7:     category = categories[1]
        default:    category = categories[2]
        }
    }
    
    public var patchJson: PatchReviewJson {
        var patch = PatchReviewJson()
        patch.anonymous = self.anonymous
        patch.feedbackText = self.feedbackText ?? ""
        patch.otherReasonText = self.otherReasonText ?? ""
        patch.score = self.score ?? -1
        patch.reasons = []
        let questions: [Question] = self.category?.questions ?? []
        patch.reasons = questions.compactMap({ question in
            question.answer.isChecked ? question.serverId : nil
        })
        return patch
    }
    
    public init(
        accessToken: String?,
        uuid: String? = nil,
        score: Int? = nil,
        category: QuestionCategory? = nil,
        hostName: String? = nil,
        projectName: String? = nil,
        companyName: String? = nil,
        anonymous: Bool = true,
        otherReasonText: String = "",
        feedbackText: String = "",
        downloadedReasons: [Int] = []
    ) {
        self.accessToken = accessToken
        self.reviewUuid = uuid
        self.score = score
        self.category = category
        self.hostName = hostName
        self.projectName = projectName
        self.companyName = companyName
        self.anonymous = anonymous
        self.feedbackText = feedbackText
        self.downloadedReasonIds = downloadedReasons
    }
}
