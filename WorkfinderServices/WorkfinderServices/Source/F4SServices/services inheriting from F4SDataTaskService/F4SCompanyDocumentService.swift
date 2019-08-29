//
//  F4SCompanyDocumentService.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 23/04/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation
import WorkfinderCommon
import WorkfinderNetworking

public struct F4SGetCompanyDocuments: Codable {
    public var companyUuid: F4SUUID?
    public var documents: F4SCompanyDocuments?
    public var possibleDocumentTypes: [String]?
}

extension F4SGetCompanyDocuments {
    private enum CodingKeys: String, CodingKey {
        case companyUuid = "uuid"
        case documents = "requested_documents"
        case possibleDocumentTypes = "possible_doc_types"
    }
}

public class F4SCompanyDocumentService: F4SDataTaskService {

    public init() {
        let apiName = "company"
        super.init(baseURLString: WorkfinderEndpoint.baseUrl2, apiName: apiName)
    }
    
    public func requestDocuments(companyUuid: F4SUUID, documents: F4SCompanyDocuments, completion: @escaping ((F4SNetworkResult<F4SJSONBoolValue>) -> ())) {
        let attempting = "Request documents"
        relativeUrlString = "companyUuid/documents"
        beginSendRequest(verb: .post, objectToSend: documents, attempting: attempting) {
            dataResult in
            switch dataResult {
            case .error(let error):
                completion(F4SNetworkResult.error(error))
            case .success(_):
                completion(F4SNetworkResult.success(F4SJSONBoolValue(value: true)))
            }
        }
    }
    
    public func getDocuments(companyUuid: F4SUUID, completion: @escaping (F4SNetworkResult<F4SGetCompanyDocuments>)->()) {
        let attempting = "Get company documents"
        relativeUrlString = "companyUuid/documents"
        beginGetRequest(attempting: attempting, completion: completion)
    }
    
}
