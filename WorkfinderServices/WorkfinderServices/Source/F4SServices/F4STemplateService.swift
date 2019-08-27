//
//  F4STemplateService.swift
//  f4s-workexperience
//
//  Created by Timea Tivadar on 11/28/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import Foundation
import WorkfinderCommon
import WorkfinderNetworking

public class F4STemplateService: F4STemplateServiceProtocol {
    
    public init() {
        
    }
    
    public func getTemplates(completion: @escaping (F4SNetworkResult<[F4STemplate]>) -> Void) {
        let attempting = "Get templates"
        let url = URL(string: WorkfinderEndpoint.templateUrl)!
        let request = F4SDataTaskService.urlRequest(verb: .get, url: url, dataToSend: nil)
        let session = F4SNetworkSessionManager.shared.interactiveSession
        let dataTask = F4SDataTaskService.networkTask(with: request, session: session, attempting: attempting) { (result) in
            switch result {

            case .error(let error):
                completion(F4SNetworkResult.error(error))
            case .success(let data):
                guard let data = data else {
                    let noData = F4SNetworkDataErrorType.noData.error(attempting: attempting)
                    completion(F4SNetworkResult.error(noData))
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    let templates = try decoder.decode([F4STemplate].self, from: data)
                    completion(F4SNetworkResult.success(templates))
                } catch {
                    let deserializationError = F4SNetworkDataErrorType.deserialization(data).error(attempting: attempting)
                    completion(F4SNetworkResult.error(deserializationError))
                }
            }
        }
        dataTask.resume()
    }
}
