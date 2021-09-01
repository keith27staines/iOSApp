//
//  ProjectsService.swift
//  WorkfinderRecommendationsList
//
//  Created by Keith on 13/08/2021.
//  Copyright © 2021 Workfinder. All rights reserved.
//

import Foundation
import WorkfinderCommon
import WorkfinderServices

public protocol OpportunitiesServiceProtocol {
    func fetchProject(uuid: F4SUUID, completion: @escaping (Result<ProjectJson,Error>) -> Void)
    func fetchFeaturedOpportunities(completion: @escaping (Result<ServerListJson<ProjectJson>, Error>) -> Void)
    func fetchRecentOpportunities(completion: @escaping (Result<ServerListJson<ProjectJson>, Error>) -> Void)
}

public class OpportuntiesService: WorkfinderService, OpportunitiesServiceProtocol {

    public func fetchProject(uuid: F4SUUID, completion: @escaping (Result<ProjectJson,Error>) -> Void) {
        do {
            let relativePath = "projects/\(uuid)/"
            let request = try buildRequest(relativePath: relativePath, queryItems: nil, verb: .get)
            performTask(with: request, completion: completion, attempting: #function)
        } catch {
            completion(.failure(error))
        }
    }
    
    public func fetchFeaturedOpportunities(completion: @escaping (Result<ServerListJson<ProjectJson>, Error>) -> Void) {
        do {
            let verbose = false
            let query = [URLQueryItem(name: "promote_on_home_page", value: "true"), URLQueryItem(name: "status", value: "open")]
            let request = try buildRequest(relativePath: projectsPath, queryItems: query, verb: .get)
            performTask(with: request, verbose: verbose, completion: completion, attempting: #function)
        } catch {
            completion(.failure(error))
        }
    }
    
    var projectsPath = UserRepository().isCandidateLoggedIn ? "projects/candidate_projects/" : "projects/"
    
    public func fetchRecentOpportunities(completion: @escaping (Result<ServerListJson<ProjectJson>, Error>) -> Void) {
        do {
            let verbose = true
            let query = [
                URLQueryItem(name: "promote_on_home_page", value: "false"),
                URLQueryItem(name: "status", value: "open")
            ]
            let path = projectsPath
            let request = try buildRequest(relativePath: path, queryItems: query, verb: .get)
            performTask(with: request, verbose: verbose, completion: completion, attempting: #function)
        } catch {
            completion(.failure(error))
        }
    }
    
    public func fetchNextPage(urlString: String, completion: @escaping (Result<ServerListJson<RoleData>, Error>) -> Void) {
        do {
            let verbose = false
            let request = try buildRequest(path: urlString, queryItems: nil, verb: .get)
            performTask(with: request, verbose: verbose, completion: completion, attempting: #function)
        } catch {
            completion(.failure(error))
        }
    }
}
