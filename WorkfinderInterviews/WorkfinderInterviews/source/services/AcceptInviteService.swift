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
        let date1 = Date().addingTimeInterval(24*3600*7).workfinderDateString
        let date2 = Date().addingTimeInterval(24*3600*14).workfinderDateString
        let date3 = Date().addingTimeInterval(24*3600*21).workfinderDateString
        let dates = [date1, date2, date3]
        let invite = InterviewInvite(id: id, projectId: "projectId", possibleDates: dates, selectedDateIndex: 0)
        completion(Result.success(invite))
    }
    
    func acceptInvite(_ interview: InterviewInvite, completion: @escaping (Error?) -> Void) {
        completion(nil)
    }
    
}
