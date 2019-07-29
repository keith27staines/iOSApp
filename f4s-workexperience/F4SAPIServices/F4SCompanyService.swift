//
//  F4SCompanyService.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 08/08/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit
import WorkfinderCommon
import WorkfinderNetworking

public struct F4SCompanyJson : Codable {
    var linkedInUrlString: String?
    var duedilUrlString: String?
    var linkedinUrl: URL? {
        return URL(string: self.linkedInUrlString ?? "")
    }
    var duedilUrl: URL? {
        return URL(string: self.duedilUrlString ?? "")
    }
}

extension F4SCompanyJson {
    private enum CodingKeys : String, CodingKey {
        case linkedInUrlString = "linkedin_url"
        case duedilUrlString = "duedil_url"
    }
}

public protocol F4SCompanyServiceProtocol {
    func getCompany(uuid: F4SUUID, completion: @escaping (F4SNetworkResult<F4SCompanyJson>) -> ())
}

class F4SCompanyService : F4SCompanyServiceProtocol {
    
    private var dataTask: F4SNetworkTask?
    
    func getCompany(uuid: F4SUUID, completion: @escaping (F4SNetworkResult<F4SCompanyJson>) -> ()) {
        let attempting = "Get company"
        var url = URL(string: WorkfinderEndpoint.companyUrl)!
        url.appendPathComponent(uuid)
        let session = F4SNetworkSessionManager.shared.interactiveSession
        let urlRequest = F4SDataTaskService.urlRequest(verb: .get, url: url, dataToSend: nil)
        dataTask?.cancel()
        dataTask = F4SDataTaskService.networkTask(with: urlRequest, session: session, attempting: attempting) { (result) in
            switch result {
            case .error(let error):
                completion(F4SNetworkResult.error(error))
            case .success(let data):
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
                decoder.decode(data: data, intoType: F4SCompanyJson.self, attempting: attempting, completion: completion)
            }
        }
        dataTask?.resume()
    }
}












