//
//  InterviewsService.swift
//  WorkfinderServices
//
//  Created by Keith on 02/09/2021.
//  Copyright © 2021 Workfinder. All rights reserved.
//

import WorkfinderCommon

public protocol InterviewServiceProtocol {
    func fetchInterviews(completion: @escaping (Result<ServerListJson<InterviewJson>,Error>) -> Void)
    func fetchInterview(uuid: String, completion: @escaping (Result<InterviewJson,Error>) -> Void)
}

public class InterviewService: WorkfinderService, InterviewServiceProtocol {
    
    public func fetchInterviews(completion: @escaping (Result<ServerListJson<InterviewJson>, Error>) -> Void) {
        do {
            let request = try buildRequest(relativePath: "interviews/", queryItems: nil, verb: .get)
            performTask(with: request, verbose: true ,completion: completion, attempting: #function)
        } catch {
            completion(.failure(error))
        }
    }
    
    public func fetchInterview(uuid: String, completion: @escaping (Result<InterviewJson, Error>) -> Void) {
        do {
            let request = try buildRequest(relativePath: "interviews/\(uuid)", queryItems: nil, verb: .get)
            performTask(with: request, verbose: true ,completion: completion, attempting: #function)
        } catch {
            completion(.failure(error))
        }
    }
    
}
