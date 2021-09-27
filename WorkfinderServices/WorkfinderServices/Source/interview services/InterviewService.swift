//
//  InterviewsService.swift
//  WorkfinderServices
//
//  Created by Keith on 02/09/2021.
//  Copyright © 2021 Workfinder. All rights reserved.
//

import WorkfinderCommon

public protocol InterviewServiceProtocol {
    func fetchInterviews(completion: @escaping (Result<[InterviewJson],Error>) -> Void)
    func fetchInterview(id: Int, completion: @escaping (Result<InterviewJson,Error>) -> Void)
}

public class InterviewService: WorkfinderService, InterviewServiceProtocol {
    
    let relativePath = "candidate-interviews/"
    
    public func fetchInterviews(completion: @escaping (Result<[InterviewJson], Error>) -> Void) {
        do {
            let request = try buildRequest(relativePath: relativePath, queryItems: nil, verb: .get)
            performTask(with: request, verbose: true ,completion: completion, attempting: #function)
        } catch {
            completion(.failure(error))
        }
    }
    
    public func fetchInterview(id: Int, completion: @escaping (Result<InterviewJson, Error>) -> Void) {
        do {
            let request = try buildRequest(relativePath: "\(relativePath)\(id)/", queryItems: nil, verb: .get)
            performTask(with: request, verbose: true ,completion: completion, attempting: #function)
        } catch {
            completion(.failure(error))
        }
    }
    
}
