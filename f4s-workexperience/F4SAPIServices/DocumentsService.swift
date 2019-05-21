//
//  DocumentsService.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 21/02/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation
import WorkfinderCommon

public protocol F4SUserDocumentsServiceProtocol {
    func getDocuments(completion: @escaping (F4SNetworkResult<F4SGetDocumentJson>) -> ())
}

public class F4SUserDocumentsService : F4SDataTaskService, F4SUserDocumentsServiceProtocol {
    
    public init() {
        let apiName = "documents"
        super.init(baseURLString: Config.BASE_URL2, apiName: apiName)
    }
    
    public func getDocuments(completion: @escaping (F4SNetworkResult<F4SGetDocumentJson>) -> ()) {
        beginGetRequest(attempting: "Get document for the current user", completion: completion)
    }
}


public protocol F4SPlacementDocumentServiceProtocol {
    var apiName: String { get }
    var placementUuid: String { get }
    func getDocuments(completion: @escaping (F4SNetworkResult<F4SGetDocumentJson>) -> ())
    func putDocuments(documents: F4SPutDocumentsJson, completion: @escaping ((F4SNetworkDataResult) -> Void ))
}

public class F4SPlacementDocumentsService : F4SDataTaskService {
    public let placementUuid: String
    
    public init(placementUuid: F4SUUID) {
        self.placementUuid = placementUuid
        let apiName = "placement/\(placementUuid)/documents"
        super.init(baseURLString: Config.BASE_URL2, apiName: apiName)
    }
}

// MARK:- F4SDocumentServiceProtocol conformance
extension F4SPlacementDocumentsService : F4SPlacementDocumentServiceProtocol {
    public func getDocuments(completion: @escaping (F4SNetworkResult<F4SGetDocumentJson>) -> ()) {
        beginGetRequest(attempting: "Get supporting document urls for this placement", completion: completion)
    }
    
    public func putDocuments(documents: F4SPutDocumentsJson, completion: @escaping ((F4SNetworkDataResult) -> Void )) {
        super.beginSendRequest(verb: .put, objectToSend: documents, attempting: "Upload supporting document urls for this placement", completion: completion)
    }
}

