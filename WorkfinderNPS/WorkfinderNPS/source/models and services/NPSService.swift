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
    func fetchNPS(uuid: String, completion: @escaping (Result<GetReviewJson, Error>) -> Void)
    func patchNPS(nps: NPSModel, completion: @escaping (Result<NPSModel, Error>) -> Void)
}

public class NPSService: WorkfinderService, NPSServiceProtocol {
        
    /* for testing
     uuid: cc59a4f4-0c2b-47e1-9c98-77b80c3f400f
     access_token: 7TomNR3W1OowciVeO2IZgpjMJph330oppq0OLylCDZM
     */
    
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
    
    func fetchNPS(uuid: String, completion: @escaping (Result<GetReviewJson, Error>) -> Void) {
        do {
            let request = try buildRequest(relativePath: "reviews/\(uuid)", queryItems: nil, verb: .get)
            performTask(with: request, verbose: true, completion: completion, attempting: "fetchNPS")
        } catch {
            completion(.failure(error))
        }
    }
    
    private func makeAccessTokenQueryItem(accessToken: String) -> URLQueryItem {
        URLQueryItem(name: "access_token", value: accessToken)
    }
    
    public func patchNPS(nps: NPSModel, completion: @escaping (Result<NPSModel, Error>) -> Void) {
        patchNPSWorker(accessToken: nps.accessToken ?? "", uuid: nps.reviewUuid ?? "", patch: nps.patchJson) { result in
            switch result {
            case .success(_):
                completion(.success(nps))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func patchNPSWorker(accessToken: String, uuid: String, patch: PatchReviewJson, completion: @escaping (Result<PatchReviewJson, Error>) -> Void) {
        do {
            let query = makeAccessTokenQueryItem(accessToken: accessToken)
            let request = try buildRequest(relativePath: "reviews/\(uuid)", verb: .patch , body: patch, queryItems: [query])
            performTask(with: request, verbose: true, completion: completion, attempting: "patchNPS")
        } catch {
            completion(.failure(error))
        }
    }
}
