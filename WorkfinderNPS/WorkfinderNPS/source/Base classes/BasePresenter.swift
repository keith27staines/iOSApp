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
    
    func setScore(_ score: Score?) {
        npsModel?.score = score?.rawValue
    }
    
    var introText: String? {
        guard let hostName = hostName, let projectName = projectName else { return nil }
        return "Based on your experience with \(hostName) on \(projectName), on a scale of 0 to 10, how likely would you recommend \(hostName) to other candidates?"
    }
    
    private var categories: [QuestionCategory]?
    
    var category: QuestionCategory? {
        guard let categories = categories, let score = npsModel?.score else { return nil }
        switch score {
        case 0..<7: return categories[0]
        case 7: return categories[1]
        case 7... : return categories[2]
        default: return nil
        }
    }
    
    func onViewDidLoad(vc: BaseViewController) {
        self.viewController = vc
    }
    
    func reload(completion: (Error?) -> Void) {
        
        service.fetchNPS(uuid: "uuid") { (result) in
            switch result {
            case .success(var nps):
                npsModel = nps
                let category = questionCategoriesBuilder(hostName: "Keith")[0]
                nps.category = category
                categories = questionCategoriesBuilder(hostName: npsModel?.hostName ?? "unknown")
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    init(coordinator: WorkfinderNPSCoordinator, service: NPSServiceProtocol) {
        self.coordinator = coordinator
        self.service = service
    }
    
    private func questionCategoriesBuilder(hostName: String) -> [QuestionCategory] {
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

        return categories
    }
    
}
