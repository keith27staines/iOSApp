//
//  NPSService.swift
//  WorkfinderNPS
//
//  Created by Keith on 23/04/2021.
//

import Foundation
import WorkfinderCommon
import WorkfinderServices

protocol NPSServiceProtocol {
    func fetchReasons(completion: @escaping (Result<[ReasonJson], Error>) -> Void)
    func fetchNPS(uuid: String, completion: (Result<NPSModel, Error>) -> Void)
    func patchNPS(uuid: String, nps: NPSModel, completion: (Result<NPSModel, Error>) -> Void)
}

public class NPSService: WorkfinderService, NPSServiceProtocol {
    
    func fetchReasons(completion: @escaping (Result<[ReasonJson], Error>) -> Void) {
        performFetchReasons { result in
            switch result {
            case .success(let reasons):
                let candidateReasons = reasons.filter { reason in
                    reason.candidateReviewingHost == true
                }
                completion(.success(candidateReasons))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func performFetchReasons(completion: @escaping (Result<[ReasonJson], Error>) -> Void) {
        do {
            let request = try buildRequest(path: "reviews/reasons/", queryItems: nil, verb: .get)
            performTask(with: request, verbose: true, completion: completion, attempting: "fetchReasons")
        } catch(let error) {
            completion(.failure(error))
        }
    }
    
    public func fetchNPS(uuid: String, completion: (Result<NPSModel, Error>) -> Void) {
        let nps = NPSModel(reviewUuid: "uuid", score: nil, category: nil, hostName: "Keith", projectName: "iOS App", companyName: "Workfinder")
        completion(.success(nps))
    }
    
    public func patchNPS(uuid: String, nps: NPSModel, completion: (Result<NPSModel, Error>) -> Void) {
        
    }
    
    
    public func fetch(uuid: String, completion: (Result<NPSModel, Error>) -> Void) {
        
    }
    
    public func patch(uuid: String, nps: NPSModel, completion: (Result<NPSModel, Error>) -> Void) {
    
    }
}
