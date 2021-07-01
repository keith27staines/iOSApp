//
//  SocialMediaData.swift
//  WorkfinderCandidateProfile
//
//  Created by Keith on 30/06/2021.
//

import Foundation
import WorkfinderCommon
import WorkfinderServices

class SocialMediaService: WorkfinderService {
    
    func getLinkedInData(completion: @escaping (Result<LinkedinConnectionData,Error>) -> Void) {
        do {
            let request = try buildRequest(relativePath: "/v3/auth/accounts/social/connections/0", queryItems: nil, verb: .get)
            performTask(with: request, verbose: true, completion: completion, attempting: "GET linkedin data")
        } catch {
            
        }
    }
    

    
}
