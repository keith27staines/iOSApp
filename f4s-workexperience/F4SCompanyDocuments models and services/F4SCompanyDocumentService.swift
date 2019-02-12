//
//  F4SCompanyDocumentService.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 23/04/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation

fileprivate struct Json : Codable {
    var requested_documents: [[String : String]]
    init(documents: F4SCompanyDocuments) {
        requested_documents = [[String:String]]()
        for document in documents {
            if let docType = document.docType {
                requested_documents.append(["doc_type" : docType])
            }
        }
    }
}

public class F4SCompanyDocumentService {
    
    private var dataTask: URLSessionDataTask?

    
    public func requestDocuments(companyUuid: F4SUUID, documents: F4SCompanyDocuments, completion: @escaping ((F4SNetworkResult<Bool>) -> ())) {
        let json = Json(documents: documents)
        let attempting = "Request company documents"
        var url = URL(string: ApiConstants.companyDocumentsUrl)!
        url.appendPathComponent(companyUuid)
        url.appendPathComponent("documents")
        let session = F4SNetworkSessionManager.shared.interactiveSession
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(json)
            log.debug("updating placement with json \n\(String(data: data, encoding: .utf8)!)")
            let urlRequest = F4SDataTaskService.urlRequest(verb: .post, url: url, dataToSend: data)
            let dataTask = F4SDataTaskService.dataTask(with: urlRequest, session: session, attempting: attempting) { result in
                switch result {
                case .error(let error):
                    completion(F4SNetworkResult.error(error))
                case .success(_):
                    completion(F4SNetworkResult.success(true))
                }
            }
            dataTask.resume()
        } catch {
            let serializationError = F4SNetworkDataErrorType.serialization(json).error(attempting: attempting)
            completion(F4SNetworkResult.error(serializationError))
        }
    }
    
    public func getDocuments(companyUuid: F4SUUID, completion: @escaping (F4SNetworkResult<F4SGetCompanyDocuments>)->()) {
        
        let attempting = "Get company documents"
        var url = URL(string: ApiConstants.companyDocumentsUrl)!
        url.appendPathComponent(companyUuid)
        url.appendPathComponent("documents")
        let session = F4SNetworkSessionManager.shared.interactiveSession
        let urlRequest = F4SDataTaskService.urlRequest(verb: .get, url: url, dataToSend: nil)
        dataTask?.cancel()
        dataTask = F4SDataTaskService.dataTask(with: urlRequest, session: session, attempting: attempting) { (result) in
            switch result {
            case .error(let error):
                completion(F4SNetworkResult.error(error))
            case .success(let data):
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
                decoder.decode(data: data, intoType: F4SGetCompanyDocuments.self, attempting: attempting, completion: completion)
            }
        }
        dataTask?.resume()
    }
}
