//
//  AcceptInviteService.swift
//  WorkfinderInterviews
//
//  Created by Keith on 14/07/2021.
//

import Foundation
import WorkfinderCommon

public class InviteService: WorkfinderService {
    
    private let _projectService: ProjectServiceProtocol
    
    public override init(networkConfig: NetworkConfig) {
        _projectService = ProjectService(networkConfig: networkConfig)
        super.init(networkConfig: networkConfig)
    }
    
    public func loadProject(uuid: String, completion: @escaping (Result<ProjectJson, Error>) -> Void) {
        _projectService.fetchProject(uuid: uuid, completion: completion)
    }
    
    public func loadInterview(id: Int, completion: @escaping (Result<InterviewJson,Error>) -> Void) {
        do {
            let request = try buildRequest(path: "candidate-interviews/\(id)/", queryItems: [], verb: .get)
            performTask(with: request, verbose: true, completion: completion, attempting: "loadInterview")
        } catch {
            completion(.failure(error))
        }
    }
    
    public struct StatusJson: Codable {
        public var status: String?
    }
    
    public func accept(_ interviewDate: InterviewJson.InterviewDateJson, completion: @escaping (Result<StatusJson,Error>) -> Void) {
        do {
            let id = interviewDate.id ?? -1
            let patch = StatusJson(status: "selected")
            let request = try buildRequest(relativePath: "interview-date/\(id)/", verb: .patch, body: patch)
            performTask(with: request,verbose: true, completion: completion, attempting: "acceptInterviewDate")
        } catch {
            completion(.failure(error))
        }
    }
    
    public func declineInterview(uuid: F4SUUID, completion: @escaping (Result<StatusJson, Error>) -> Void) {
        do {
            let patch = StatusJson(status: "interview_decline")
            let request = try buildRequest(relativePath: "interviews/\(uuid)/", verb: .patch, body: patch)
            performTask(with: request,verbose: true, completion: completion, attempting: "loadInterview")
        } catch {
            completion(.failure(error))
        }
    }
}
