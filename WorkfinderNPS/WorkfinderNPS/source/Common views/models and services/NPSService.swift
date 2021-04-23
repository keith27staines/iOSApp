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
    func fetchNPS(uuid: String, completion: (Result<NPS, Error>) -> Void)
    func patchNPS(uuid: String, nps: NPS, completion: (Result<NPS, Error>) -> Void)
}

public class NPSService: WorkfinderService, NPSServiceProtocol {
    public func fetchNPS(uuid: String, completion: (Result<NPS, Error>) -> Void) {
        
    }
    
    public func patchNPS(uuid: String, nps: NPS, completion: (Result<NPS, Error>) -> Void) {
        
    }
    
    
    public func fetch(uuid: String, completion: (Result<NPS, Error>) -> Void) {
        
    }
    
    public func patch(uuid: String, nps: NPS, completion: (Result<NPS, Error>) -> Void) {
    
    }
}
