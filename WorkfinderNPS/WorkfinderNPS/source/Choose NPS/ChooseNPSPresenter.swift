//
//  ChooseNPSPresenter.swift
//  WorkfinderNPS
//
//  Created by Keith on 23/04/2021.
//

import Foundation
import WorkfinderCommon

class ChooseNPSPresenter: BasePresenter {
        
    var introText: String? {
        guard let hostName = hostName, let projectName = projectName else { return nil }
        return "Based on your experience with \(hostName) on \(projectName), on a scale of 0 to 10, how likely would you be to recommend \(hostName) to other candidates?"
    }
    
    func setScore(_ score: Score?) {
        npsModel.setScore(score)
    }

    func reload(completion: @escaping (Error?) -> Void) {
        fetchReasons { [weak self] reasonResult in
            switch reasonResult {
            case .success(let allQuestions):
                let uuid = self?.npsModel.reviewUuid ?? ""
                self?.fetchNPS(uuid: uuid) { [weak self] npsResult in
                    guard let self = self else { return }
                    switch npsResult {
                    case .success(let reviewJson):
                        self.npsModel.reloadFrom(reviewJson: reviewJson, allQuestions: allQuestions)
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
    
    private func fetchNPS(uuid: String, completion: @escaping (Result<GetReviewJson,Error>) -> Void) {
        self.service.fetchNPS(uuid: uuid) { (result) in
            completion(result)
        }
    }

}
