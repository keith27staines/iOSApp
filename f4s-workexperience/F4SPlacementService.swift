//
//  F4SPlacementService.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 21/06/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation

public protocol F4SPlacementServiceProtocol {
    func createPlacement(placement: F4SPlacement, completion: @escaping (_ result: F4SNetworkResult<F4SPlacementCreateResult>) -> ())
    func getAllPlacementsForUser(completed: @escaping (_ result: F4SNetworkResult<[F4STimeline]>) -> ())

}

public class F4SPlacementService : F4SPlacementServiceProtocol {
    
    public func createPlacement(placement: F4SPlacement, completion: @escaping (F4SNetworkResult<F4SPlacementCreateResult>) -> ()) {
        let attempting = "Create placement"
        let url = URL(string: ApiConstants.createPlacementUrl)!
        let session = F4SNetworkSessionManager.shared.interactiveSession
        let params: [String: Any] = [
            "company_uuid" : placement.companyUuid!,
            "interests" : placement.interestList
        ]
        do {
            //let encoder = JSONEncoder()
            //let data = try encoder.encode(p)
            let data: Data? = nil
            var urlRequest = F4SDataTaskService.urlRequest(verb: .post, url: url, dataToSend: data)
            params.forEach { (key,value) in
                urlRequest.setValue(<#T##value: String?##String?#>, forHTTPHeaderField: <#T##String#>)
            }
            let dataTask = F4SDataTaskService.dataTask(with: urlRequest, session: session, attempting: attempting) { [weak self] (result) in
                
                self?.handleCreateplacementTaskResult(attempting: attempting, dataResult: result, completion: completion)
                
            }
            dataTask.resume()
        } catch {
            let serializationError = F4SNetworkDataErrorType.serialization(placement).error(attempting: attempting)
            completion(F4SNetworkResult.error(serializationError))
        }

    }
    
    func handleCreateplacementTaskResult(attempting: String, dataResult: F4SNetworkDataResult, completion: @escaping (F4SNetworkResult<F4SPlacementCreateResult>) -> ()) {
        DispatchQueue.main.async {
            let decoder = JSONDecoder()
            decoder.decode(dataResult: dataResult, intoType: F4SPlacementCreateResult.self, attempting: attempting, completion: completion)
        }
    }
    
    public func getAllPlacementsForUser(completed: @escaping (F4SNetworkResult<[F4STimeline]>) -> ()) {
        
    }
}
