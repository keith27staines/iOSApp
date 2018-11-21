//
//  DocumentsService.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 21/02/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation

public protocol F4SDocumentServiceProtocol {
    var apiName: String { get }
    var placementUuid: String { get }
    func getDocumentsForPlacement(completion: @escaping (F4SNetworkResult<F4SGetDocumentJson>) -> ())
    func putDocumentsForPlacement(documents: F4SPutDocumentsJson, completion: @escaping ((F4SNetworkDataResult) -> Void ))
}

public class F4SPlacementDocumentsService : F4SDataTaskService {
    public let placementUuid: String
    
    public init(placementUuid: F4SUUID) {
        self.placementUuid = placementUuid
        let apiName = "placement/\(placementUuid)/documents"
        super.init(baseURLString: Config.BASE_URL, apiName: apiName)
    }
}

// MARK:- F4SDocumentServiceProtocol conformance
extension F4SPlacementDocumentsService : F4SDocumentServiceProtocol {
    public func getDocumentsForPlacement(completion: @escaping (F4SNetworkResult<F4SGetDocumentJson>) -> ()) {
        beginGetRequest(attempting: "Get supporting document urls for this placement", completion: completion)
    }
    
    public func putDocumentsForPlacement(documents: F4SPutDocumentsJson, completion: @escaping ((F4SNetworkDataResult) -> Void )) {
        super.beginSendRequest(verb: .put, objectToSend: documents, attempting: "Upload supporting document urls for this placement", completion: completion)
    }
}

