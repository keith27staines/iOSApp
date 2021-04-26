//
//  NPSService.swift
//  WorkfinderNPS
//
//  Created by Keith on 23/04/2021.
//

import Foundation
import WorkfinderCommon
import WorkfinderServices

public protocol NPSServiceProtocol {
    func fetchNPS(uuid: String, completion: (Result<NPSModel, Error>) -> Void)
    func patchNPS(uuid: String, nps: NPSModel, completion: (Result<NPSModel, Error>) -> Void)
}

public class NPSService: WorkfinderService, NPSServiceProtocol {
    public func fetchNPS(uuid: String, completion: (Result<NPSModel, Error>) -> Void) {
        let nps = NPSModel(reviewUuid: "uuid", score: nil, category: nil, hostName: "Keith", projectName: "Apollo", companyName: "Workfinder")
        completion(.success(nps))
    }
    
    public func patchNPS(uuid: String, nps: NPSModel, completion: (Result<NPSModel, Error>) -> Void) {
        
    }
    
    
    public func fetch(uuid: String, completion: (Result<NPSModel, Error>) -> Void) {
        
    }
    
    public func patch(uuid: String, nps: NPSModel, completion: (Result<NPSModel, Error>) -> Void) {
    
    }
}
