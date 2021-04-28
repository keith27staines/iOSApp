//
//  BasePresenter.swift
//  WorkfinderNPS
//
//  Created by Keith on 23/04/2021.
//

import Foundation


class BasePresenter {
    
    weak var coordinator: WorkfinderNPSCoordinator?
    var service: NPSServiceProtocol
    weak var viewController: BaseViewController?
    var npsModel: NPSModel?
    
    var hostName: String? { npsModel?.hostName }
    var projectName: String? { npsModel?.projectName }
    var companyName: String? { npsModel?.companyName }
    var score: Int? { npsModel?.score }
    
    var feedbackIntro: String {
        let hostName = self.hostName ?? ""
        let companyName = self.companyName ?? ""
        return "Your feedback is highly valuable to \(hostName), \(companyName) and us. This helps us improve our service so that you and other candidates won’t have similar experience again. You can choose to hide your name and details when sharing your feedback."
    }
    
    var allQuestions = [Question]() {
        didSet {
            categories?.forEach({ category in
                category.questions = allQuestions
            })
        }
    }
    
    func setScore(_ score: Score?) {
        let scoreValue = score?.rawValue
        npsModel?.score = scoreValue
    }
    
    var introText: String? {
        guard let hostName = hostName, let projectName = projectName else { return nil }
        return "Based on your experience with \(hostName) on \(projectName), on a scale of 0 to 10, how likely would you recommend \(hostName) to other candidates?"
    }
    
    private var categories: [QuestionCategory]?
    
    var category: QuestionCategory? {
        guard let categories = categories, let score = score else { return nil }
        switch score {
        case 0..<7: return categories[0]
        case 7:     return categories[1]
        default:    return categories[2]
        }
    }
    
    func onViewDidLoad(vc: BaseViewController) {
        self.viewController = vc
    }
    
    func reload(completion: @escaping (Error?) -> Void) {
        fetchReasons { [weak self] reasonResult in
            switch reasonResult {
            case .success(let allQuestions):
                self?.fetchNPS(uuid: "uuid") { [weak self] npsResult in
                    guard let self = self else { return }
                    switch npsResult {
                    case .success(let nps):
                        self.allQuestions = allQuestions
                        self.npsModel = nps
                        self.buildCategories(hostName: nps.hostName ?? "", allQuestions: allQuestions)
                        self.npsModel?.category = self.category
                        completion(nil)
                    case .failure(let error):
                        completion(error)
                    }
                }
            case .failure(let error):
                completion(error)
            }
            
        }
    }
    
    private func fetchReasons(completion: @escaping (Result<[Question],Error>) -> Void) {
        service.fetchReasons { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let reasons):
                    let allQuestions = reasons.map({ reason in
                        Question(reason: reason)
                    })
                    completion(.success(allQuestions))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }

    
    private func fetchNPS(uuid: String, completion: @escaping (Result<NPSModel,Error>) -> Void) {
        self.service.fetchNPS(uuid: "uuid") { (result) in
            completion(result)
        }
    }
    
    init(coordinator: WorkfinderNPSCoordinator, service: NPSServiceProtocol) {
        self.coordinator = coordinator
        self.service = service
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
    
}
