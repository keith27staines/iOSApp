//
//  F4SRoleService.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 30/07/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation
import WorkfinderCommon
import WorkfinderNetworking
import WorkfinderServices

public class F4SRoleService {
    
    private var dataTask: F4SNetworkTask?
    
    public func getRoleForCompany(companyUuid: F4SUUID, roleUuid: F4SUUID, completion: @escaping (F4SNetworkResult<F4SRoleJson>) -> ()) {
        let attempting = "Get role"
        var url = URL(string: WorkfinderEndpoint.roleUrl)!
        url.appendPathComponent(companyUuid)
        url.appendPathComponent("roles")
        url.appendPathComponent(roleUuid)
        let session = F4SNetworkSessionManager.shared.interactiveSession
        let urlRequest = F4SDataTaskService.urlRequest(verb: .get, url: url, dataToSend: nil)
        dataTask?.cancel()
        dataTask = F4SDataTaskService.networkTask(with: urlRequest, session: session, attempting: attempting) { (result) in
            switch result {
            case .error(let error):
                completion(F4SNetworkResult.error(error))
            case .success(let data):
                let decoder = JSONDecoder()
                decoder.decode(data: data, intoType: F4SRoleJson.self, attempting: attempting, completion: completion)
            }
        }
        dataTask?.resume()
    }
}
