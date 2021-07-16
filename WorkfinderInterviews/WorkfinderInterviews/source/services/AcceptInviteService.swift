//
//  AcceptInviteService.swift
//  WorkfinderInterviews
//
//  Created by Keith on 14/07/2021.
//

import Foundation
import WorkfinderCommon
import WorkfinderServices

class InviteService: WorkfinderService {
    
    private let _projectService: ProjectServiceProtocol
    
    override init(networkConfig: NetworkConfig) {
        _projectService = ProjectService(networkConfig: networkConfig)
        super.init(networkConfig: networkConfig)
    }
    
    func loadProject(uuid: String, completion: @escaping (Result<ProjectJson, Error>) -> Void) {
        _projectService.fetchProject(uuid: uuid, completion: completion)
    }
    
    func loadInvite(id: String, completion: @escaping (Result<InterviewInvite,Error>) -> Void) {
        let invite = InterviewInvite(id: <#T##String?#>, projectId: <#T##String?#>, possibleDates: <#T##[String]?#>, selectedDateIndex: <#T##Int?#>)
    }
    
}
